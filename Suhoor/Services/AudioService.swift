import AVFoundation
import Combine
import MediaPlayer

// MARK: - Audio State

enum AudioPlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case error(String)
}

// MARK: - Audio Item

struct AudioItem: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let url: URL
    let isLocal: Bool
}

// MARK: - Audio Service

final class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()

    @Published private(set) var state: AudioPlaybackState = .idle
    @Published private(set) var currentItem: AudioItem?
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var queue: [AudioItem] = []

    private var player: AVAudioPlayer?
    private var timer: Timer?
    private let downloadManager = AudioDownloadManager()

    private override init() {
        super.init()
        configureAudioSession()
        setupRemoteCommands()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    // MARK: - Playback Controls

    func play(_ item: AudioItem) {
        currentItem = item
        state = .loading

        if item.isLocal {
            startPlayback(url: item.url)
        } else {
            Task {
                if let localURL = await downloadManager.downloadIfNeeded(item) {
                    await MainActor.run { startPlayback(url: localURL) }
                } else {
                    await MainActor.run { state = .error("Failed to load audio") }
                }
            }
        }
    }

    func pause() {
        player?.pause()
        state = .paused
        updateNowPlaying()
    }

    func resume() {
        player?.play()
        state = .playing
        updateNowPlaying()
    }

    func stop() {
        player?.stop()
        player = nil
        timer?.invalidate()
        timer = nil
        currentItem = nil
        currentTime = 0
        duration = 0
        state = .idle
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func togglePlayPause() {
        switch state {
        case .playing: pause()
        case .paused: resume()
        default: break
        }
    }

    func skipNext() {
        guard !queue.isEmpty else {
            stop()
            return
        }
        let next = queue.removeFirst()
        play(next)
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
        updateNowPlaying()
    }

    // MARK: - Private

    private func startPlayback(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            duration = player?.duration ?? 0
            state = .playing
            startTimer()
            updateNowPlaying()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.currentTime = self?.player?.currentTime ?? 0
        }
    }

    // MARK: - Now Playing

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.skipNext()
            return .success
        }

        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: event.positionTime)
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let item = currentItem else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: item.title,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: state == .playing ? 1.0 : 0.0
        ]
        if let subtitle = item.subtitle {
            info[MPMediaItemPropertyArtist] = subtitle
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !queue.isEmpty {
            skipNext()
        } else {
            stop()
        }
    }
}

// MARK: - Download Manager

final class AudioDownloadManager {
    private let cacheDirectory: URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("AudioCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    func localURL(for item: AudioItem) -> URL {
        cacheDirectory.appendingPathComponent(item.id)
    }

    func isDownloaded(_ item: AudioItem) -> Bool {
        FileManager.default.fileExists(atPath: localURL(for: item).path)
    }

    func downloadIfNeeded(_ item: AudioItem) async -> URL? {
        let local = localURL(for: item)
        if FileManager.default.fileExists(atPath: local.path) {
            return local
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: item.url)
            try data.write(to: local)
            return local
        } catch {
            print("Download error: \(error)")
            return nil
        }
    }

    func deleteDownload(for item: AudioItem) {
        try? FileManager.default.removeItem(at: localURL(for: item))
    }

    func clearCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}
