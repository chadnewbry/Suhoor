import Foundation
import AVFoundation
import MediaPlayer
import Combine

// MARK: - Quran Audio Service

/// Streams Quran recitation audio per Juz using the Quran.com API
final class QuranAudioService: NSObject, ObservableObject {
    static let shared = QuranAudioService()

    @Published private(set) var playbackState: JuzPlaybackState = .idle
    @Published private(set) var currentJuz: Int?
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    /// Reciter ID for Mishary Rashid Alafasy on Quran.com API
    private let reciterId = 7

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
            print("QuranAudioService: Audio session error: \(error)")
        }
    }

    // MARK: - Playback

    func play(juz: Int) {
        guard juz >= 1 && juz <= 30 else { return }

        stop()
        currentJuz = juz
        playbackState = .loading(juz: juz)

        Task {
            do {
                let url = try await fetchAudioURL(for: juz)
                await MainActor.run {
                    startStreaming(url: url, juz: juz)
                }
            } catch {
                await MainActor.run {
                    playbackState = .error(juz: juz, message: error.localizedDescription)
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

    func pause() {
        guard let juz = currentJuz else { return }
        player?.pause()
        playbackState = .paused(juz: juz)
        updateNowPlaying()
    }

    func resume() {
        guard let juz = currentJuz else { return }
        player?.play()
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
        playbackState = .idle
        cancellables.removeAll()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
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
                    self.player?.play()
                    self.playbackState = .playing(juz: juz)
                    if let dur = self.player?.currentItem?.duration, dur.isNumeric {
                        self.duration = CMTimeGetSeconds(dur)
                    }
                    self.updateNowPlaying()
                case .failed:
                    self.playbackState = .error(juz: juz, message: "Failed to load audio")
                default:
                    break
                }
            }
            .store(in: &cancellables)

        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            self?.currentTime = CMTimeGetSeconds(time)
            if let dur = self?.player?.currentItem?.duration, dur.isNumeric {
                self?.duration = CMTimeGetSeconds(dur)
            }
        }

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
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
