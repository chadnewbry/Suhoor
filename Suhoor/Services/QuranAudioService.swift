import Foundation
import AVFoundation
import MediaPlayer
import Combine

// MARK: - Quran Audio Service

/// Streams Quran recitation audio per Juz using the Quran.com API and Al Quran Cloud API.
/// Supports background playback, play/pause/seek, and Now Playing integration.
@MainActor
final class QuranAudioService: NSObject, ObservableObject {
    static let shared = QuranAudioService()

    // MARK: - Published State

    @Published private(set) var playbackState: JuzPlaybackState = .idle
    @Published private(set) var currentJuz: Int?
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Private

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    /// Reciter ID for Mishary Rashid Alafasy on Quran.com API
    private let reciterId = 7

    /// Base URL for Al Quran Cloud API audio.
    /// Provides per-ayah audio; we stream the first ayah of each Juz as a starting point.
    private let baseURL = "https://cdn.islamic.network/quran/audio/128/ar.alafasy"

    /// Mapping of Juz number to the global ayah number of its first ayah.
    private static let juzStartAyah: [Int: Int] = [
        1: 1, 2: 142, 3: 253, 4: 385, 5: 470, 6: 555, 7: 640, 8: 722,
        9: 800, 10: 879, 11: 957, 12: 1041, 13: 1127, 14: 1200, 15: 1282,
        16: 1363, 17: 1442, 18: 1522, 19: 1602, 20: 1680, 21: 1757,
        22: 1833, 23: 1905, 24: 1975, 25: 2048, 26: 2122, 27: 2196,
        28: 2266, 29: 2337, 30: 2402
    ]

    private override init() {
        super.init()
        configureAudioSession()
        setupRemoteCommands()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            self.error = "Failed to configure audio session: \(error.localizedDescription)"
            print("QuranAudioService: Audio session error: \(error)")
        }
    }

    // MARK: - Playback Controls

    func play(juz: Int) {
        guard juz >= 1 && juz <= 30 else { return }

        stop()
        currentJuz = juz
        playbackState = .loading(juz: juz)
        isLoading = true
        self.error = nil

        Task {
            do {
                let url = try await fetchAudioURL(for: juz)
                await MainActor.run {
                    startStreaming(url: url, juz: juz)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    playbackState = .error(juz: juz, message: error.localizedDescription)
                    self.error = error.localizedDescription
                }
            }
        }
    }

    func togglePlayPause(juz: Int) {
        switch playbackState {
        case .playing(let current) where current == juz:
            pause()
        case .paused(let current) where current == juz:
            resume()
        default:
            play(juz: juz)
        }
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    func pause() {
        guard let juz = currentJuz else { return }
        player?.pause()
        isPlaying = false
        playbackState = .paused(juz: juz)
        updateNowPlaying()
    }

    func resume() {
        guard let juz = currentJuz else { return }
        player?.play()
        isPlaying = true
        playbackState = .playing(juz: juz)
        updateNowPlaying()
    }

    func stop() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        currentJuz = nil
        currentTime = 0
        duration = 0
        isPlaying = false
        isLoading = false
        playbackState = .idle
        cancellables.removeAll()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    /// Seek to a specific time in seconds.
    func seek(to seconds: TimeInterval) {
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time)
    }

    /// Seek forward by the given number of seconds (default 10).
    func seekForward(by seconds: TimeInterval = 10) {
        let target = min(currentTime + seconds, duration)
        seek(to: target)
    }

    /// Seek backward by the given number of seconds (default 10).
    func seekBackward(by seconds: TimeInterval = 10) {
        let target = max(currentTime - seconds, 0)
        seek(to: target)
    }

    // MARK: - Private

    private func fetchAudioURL(for juz: Int) async throws -> URL {
        let chapter = juzFirstChapter(juz)
        let urlString = "https://api.quran.com/api/v4/chapter_recitations/\(reciterId)/\(chapter)"
        guard let url = URL(string: urlString) else {
            throw QuranAudioError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ChapterRecitationResponse.self, from: data)

        guard let audioURLString = response.audioFile?.audioUrl,
              let audioURL = URL(string: audioURLString) else {
            throw QuranAudioError.noAudioAvailable
        }

        return audioURL
    }

    private func startStreaming(url: URL, juz: Int) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.isLoading = false
                    self.player?.play()
                    self.isPlaying = true
                    self.playbackState = .playing(juz: juz)
                    if let dur = self.player?.currentItem?.duration, dur.isNumeric {
                        self.duration = CMTimeGetSeconds(dur)
                    }
                    self.updateNowPlaying()
                case .failed:
                    self.isLoading = false
                    self.playbackState = .error(juz: juz, message: playerItem.error?.localizedDescription ?? "Playback failed")
                    self.error = playerItem.error?.localizedDescription ?? "Playback failed"
                default:
                    break
                }
            }
            .store(in: &cancellables)

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = CMTimeGetSeconds(time)
                if let dur = self?.player?.currentItem?.duration, dur.isNumeric {
                    self?.duration = CMTimeGetSeconds(dur)
                }
            }
        }

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isPlaying = false
                self?.stop()
            }
            .store(in: &cancellables)
    }

    private func juzFirstChapter(_ juz: Int) -> Int {
        let mapping: [Int: Int] = [
            1: 1, 2: 2, 3: 2, 4: 3, 5: 4, 6: 4, 7: 5, 8: 6,
            9: 7, 10: 8, 11: 9, 12: 11, 13: 12, 14: 15, 15: 17,
            16: 18, 17: 21, 18: 23, 19: 25, 20: 27, 21: 29, 22: 33,
            23: 36, 24: 39, 25: 41, 26: 46, 27: 51, 28: 58, 29: 67, 30: 78
        ]
        return mapping[juz] ?? 1
    }

    // MARK: - Remote Commands

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

        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self, let juz = self.currentJuz else { return .commandFailed }
            self.togglePlayPause(juz: juz)
            return .success
        }

        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.player?.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: 600))
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let juz = currentJuz else { return }
        let info: [String: Any] = [
            MPMediaItemPropertyTitle: "Juz \(juz)",
            MPMediaItemPropertyArtist: "Mishary Rashid Alafasy",
            MPMediaItemPropertyAlbumTitle: "Quran Recitation",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: playbackState.isPlaying ? 1.0 : 0.0
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Audio URL Builder

    /// Returns the streaming URL for a specific ayah within a Juz.
    /// Uses the Al Quran Cloud API with Mishary Rashid Alafasy recitation.
    func audioURL(forAyah globalAyahNumber: Int) -> URL? {
        URL(string: "\(baseURL)/\(globalAyahNumber).mp3")
    }
}

// MARK: - Types

enum JuzPlaybackState: Equatable {
    case idle
    case loading(juz: Int)
    case playing(juz: Int)
    case paused(juz: Int)
    case error(juz: Int, message: String)

    var isPlaying: Bool {
        if case .playing = self { return true }
        return false
    }

    func isActive(juz: Int) -> Bool {
        switch self {
        case .loading(let j), .playing(let j), .paused(let j), .error(let j, _):
            return j == juz
        case .idle:
            return false
        }
    }
}

enum QuranAudioError: LocalizedError {
    case invalidURL
    case noAudioAvailable

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid audio URL"
        case .noAudioAvailable: return "No audio available for this recitation"
        }
    }
}

// MARK: - API Response

private struct ChapterRecitationResponse: Decodable {
    let audioFile: AudioFile?

    enum CodingKeys: String, CodingKey {
        case audioFile = "audio_file"
    }
}

private struct AudioFile: Decodable {
    let audioUrl: String?

    enum CodingKeys: String, CodingKey {
        case audioUrl = "audio_url"
    }
}
