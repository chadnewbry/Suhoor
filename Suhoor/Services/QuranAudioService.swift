import AVFoundation
import Combine
import Foundation

/// Audio player service for Quran Juz recitations using the Al Quran Cloud API.
/// Supports background playback, play/pause/seek.
@MainActor
final class QuranAudioService: NSObject, ObservableObject {
    static let shared = QuranAudioService()

    // MARK: - Published State

    @Published var isPlaying = false
    @Published var currentJuz: Int?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Private

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

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
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            self.error = "Failed to configure audio session: \(error.localizedDescription)"
        }
    }

    // MARK: - Playback Controls

    /// Start streaming the recitation for a given Juz number (1–30).
    func play(juz: Int) {
        guard let ayahNumber = Self.juzStartAyah[juz] else {
            error = "Invalid Juz number: \(juz)"
            return
        }

        stop()
        isLoading = true
        self.error = nil
        currentJuz = juz

        let urlString = "\(baseURL)/\(ayahNumber).mp3"
        guard let url = URL(string: urlString) else {
            error = "Invalid audio URL"
            isLoading = false
            return
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Observe when ready to play
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.isLoading = false
                    self.duration = playerItem.duration.seconds.isFinite ? playerItem.duration.seconds : 0
                    self.player?.play()
                    self.isPlaying = true
                case .failed:
                    self.isLoading = false
                    self.error = playerItem.error?.localizedDescription ?? "Playback failed"
                default:
                    break
                }
            }
            .store(in: &cancellables)

        // Time observer for progress
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds
            }
        }

        // Observe playback end
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isPlaying = false
            }
            .store(in: &cancellables)
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    func stop() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentJuz = nil
        cancellables.removeAll()
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

    // MARK: - Audio URL Builder

    /// Returns the streaming URL for a specific ayah within a Juz.
    /// Uses the Al Quran Cloud API with Mishary Rashid Alafasy recitation.
    func audioURL(forAyah globalAyahNumber: Int) -> URL? {
        URL(string: "\(baseURL)/\(globalAyahNumber).mp3")
    }
}
