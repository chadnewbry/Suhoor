import SwiftUI

struct QuranReadingPlanView: View {
    @StateObject private var readingService = QuranReadingService.shared
    @StateObject private var audioService = QuranAudioService.shared
    @State private var selectedDay: Int?

    private var todayReading: DailyReading? {
        let currentDay = readingService.progress.currentDay
        return readingService.progress.dailyReadings.first { $0.day == currentDay }
    }

    private var statusMessage: String {
        let completed = readingService.progress.completedJuz
        let currentDay = readingService.progress.currentDay
        let percentage = Int(readingService.progress.khatamPercentage * 100)

        if completed >= currentDay {
            return "\(percentage)% complete — on track for Khatam! 🎉"
        } else {
            let behind = currentDay - completed
            return "\(percentage)% complete — behind by \(behind) Juz"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Progress Dashboard
                progressDashboard

                // MARK: - Status Message
                Text(statusMessage)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(readingService.progress.completedJuz >= readingService.progress.currentDay ? Color.green : Color.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // MARK: - Overall Progress Bar
                VStack(spacing: 6) {
                    ProgressView(value: readingService.progress.khatamPercentage)
                        .tint(Color.suhoorGold)
                        .scaleEffect(y: 2)

                    Text("\(readingService.progress.completedJuz)/30 Juz completed")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
                .padding(.horizontal)

                // MARK: - Today's Juz (Highlighted)
                if let today = todayReading {
                    todayJuzCard(today)
                }

                // MARK: - Now Playing Mini Bar
                if audioService.playbackState.isPlaying || audioService.currentJuz != nil {
                    nowPlayingBar
                }

                // MARK: - 30-Day Juz List
                juzListSection
            }
            .padding()
        }
        .sheet(item: $selectedDay) { day in
            ReadingSessionView(day: day, readingService: readingService)
        }
    }

    // MARK: - Today's Juz Card

    private func todayJuzCard(_ reading: DailyReading) -> some View {
        let juzInfo = readingService.juzInfo(for: reading.juz)

        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Reading")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.suhoorGold)

                    if let info = juzInfo {
                        Text("Juz \(info.juz)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.suhoorTextPrimary)

                        Text("\(info.startSurah) \(info.startAyah) — \(info.endSurah) \(info.endAyah)")
                            .font(.caption)
                            .foregroundStyle(Color.suhoorTextSecondary)
                    }
                }

                Spacer()

                // Audio button
                audioButton(for: reading.juz, size: .large)

                // Complete button
                Button {
                    if reading.isComplete {
                        // Already complete — open session
                        selectedDay = reading.day
                    } else {
                        readingService.markDayComplete(day: reading.day)
                    }
                } label: {
                    Image(systemName: reading.isComplete ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundStyle(reading.isComplete ? Color.green : Color.suhoorTextSecondary.opacity(0.4))
                }
            }

            if reading.isComplete {
                Text("✅ Completed")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color.suhoorGold.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.suhoorGold, lineWidth: 2)
        )
    }

    // MARK: - Now Playing Bar

    private var nowPlayingBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform")
                .font(.body)
                .foregroundStyle(Color.suhoorGold)

            if let juz = audioService.currentJuz {
                Text("Juz \(juz)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.suhoorTextPrimary)
            }

            Spacer()

            if audioService.duration > 0 {
                Text(formatTime(audioService.currentTime))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color.suhoorTextSecondary)
            }

            Button {
                if let juz = audioService.currentJuz {
                    audioService.togglePlayPause(juz: juz)
                }
            } label: {
                Image(systemName: audioService.playbackState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.suhoorGold)
            }

            Button {
                audioService.stop()
            } label: {
                Image(systemName: "xmark.circle")
                    .font(.body)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Progress Dashboard

    private var progressDashboard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.suhoorTextSecondary.opacity(0.2), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: readingService.progress.khatamPercentage)
                    .stroke(Color.suhoorGold, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: readingService.progress.khatamPercentage)

                VStack(spacing: 4) {
                    Text("\(readingService.progress.completedJuz)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Text("of 30 Juz")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }
            .frame(width: 150, height: 150)

            if let estimated = readingService.progress.estimatedCompletionDate {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("Est. completion: \(estimated, style: .date)")
                        .font(.caption)
                }
                .foregroundStyle(Color.suhoorTextSecondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Juz List

    private var juzListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("30-Day Reading Plan")
                .font(.headline)
                .foregroundStyle(Color.suhoorTextPrimary)

            ForEach(readingService.progress.dailyReadings) { reading in
                let isToday = reading.day == readingService.progress.currentDay
                let juzInfo = readingService.juzInfo(for: reading.juz)

                Button {
                    selectedDay = reading.day
                } label: {
                    HStack(spacing: 12) {
                        // Day/Juz number
                        VStack(spacing: 2) {
                            Text("Day \(reading.day)")
                                .font(.caption2)
                                .foregroundStyle(Color.suhoorTextSecondary)
                            Text("\(reading.juz)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(isToday ? Color.suhoorGold : Color.suhoorTextPrimary)
                        }
                        .frame(width: 50)

                        // Surah range
                        VStack(alignment: .leading, spacing: 2) {
                            if let info = juzInfo {
                                Text("Juz \(info.juz)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.suhoorTextPrimary)
                                Text("\(info.startSurah) \(info.startAyah) — \(info.endSurah) \(info.endAyah)")
                                    .font(.caption)
                                    .foregroundStyle(Color.suhoorTextSecondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        // Audio button
                        audioButton(for: reading.juz, size: .small)

                        // Completion checkbox
                        Image(systemName: reading.isComplete ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(reading.isComplete ? Color.green : Color.suhoorTextSecondary.opacity(0.4))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(isToday ? Color.suhoorGold.opacity(0.15) : Color.suhoorSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isToday ? Color.suhoorGold : Color.clear, lineWidth: 2)
                    )
                }
            }
        }
    }

    // MARK: - Audio Button

    private enum AudioButtonSize {
        case small, large
    }

    private func audioButton(for juz: Int, size: AudioButtonSize) -> some View {
        Button {
            audioService.togglePlayPause(juz: juz)
        } label: {
            Group {
                if case .loading(let j) = audioService.playbackState, j == juz {
                    ProgressView()
                        .tint(Color.suhoorGold)
                } else {
                    let isPlaying = {
                        if case .playing(let j) = audioService.playbackState, j == juz { return true }
                        return false
                    }()
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(size == .large ? .title : .title3)
                        .foregroundStyle(Color.suhoorGold)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    NavigationStack {
        QuranReadingPlanView()
    }
}
