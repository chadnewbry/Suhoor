import SwiftUI

struct ReadingSessionView: View {
    let day: Int
    @ObservedObject var readingService: QuranReadingService
    @Environment(\.dismiss) private var dismiss

    @State private var pagesInput: String = ""
    @State private var isTimerRunning = false
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?

    private var reading: DailyReading? {
        readingService.progress.dailyReadings.first { $0.day == day }
    }

    private var juz: JuzInfo? {
        readingService.juzInfo(for: reading?.juz ?? day)
    }

    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Juz Header
                        if let juz {
                            VStack(spacing: 8) {
                                Text("Day \(day) — Juz \(juz.juz)")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Color.suhoorTextPrimary)

                                Text("\(juz.startSurah) \(juz.startAyah) — \(juz.endSurah) \(juz.endAyah)")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.suhoorTextSecondary)

                                Text("Pages: \(juz.totalPages) pages")
                                    .font(.caption)
                                    .foregroundStyle(Color.suhoorTextSecondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.suhoorSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // MARK: - Progress
                        if let reading {
                            VStack(spacing: 12) {
                                Text("Pages Read: \(reading.pagesRead)/\(reading.totalPages)")
                                    .font(.headline)
                                    .foregroundStyle(Color.suhoorTextPrimary)

                                ProgressView(value: reading.completionPercentage)
                                    .tint(reading.isComplete ? Color.green : Color.suhoorGold)
                                    .scaleEffect(y: 2.5)
                                    .padding(.horizontal)

                                if reading.isComplete {
                                    Label("Complete!", systemImage: "checkmark.seal.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding()
                            .background(Color.suhoorSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // MARK: - Start Reading / Deeplink
                        Button {
                            openQuranApp()
                        } label: {
                            Label("Start Reading", systemImage: "book.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.suhoorGold)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // MARK: - Reading Timer
                        VStack(spacing: 12) {
                            Text("Reading Timer")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.suhoorTextSecondary)

                            Text(formattedTime)
                                .font(.system(size: 48, weight: .light, design: .monospaced))
                                .foregroundStyle(Color.suhoorTextPrimary)

                            HStack(spacing: 16) {
                                Button {
                                    toggleTimer()
                                } label: {
                                    Label(isTimerRunning ? "Pause" : "Start",
                                          systemImage: isTimerRunning ? "pause.fill" : "play.fill")
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(isTimerRunning ? Color.orange : Color.green)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                }

                                if elapsedSeconds > 0 {
                                    Button {
                                        resetTimer()
                                    } label: {
                                        Label("Reset", systemImage: "arrow.counterclockwise")
                                            .font(.subheadline.weight(.medium))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.suhoorSurface)
                                            .foregroundStyle(Color.suhoorTextSecondary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.suhoorSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // MARK: - Log Pages
                        VStack(spacing: 12) {
                            Text("Log Pages Read")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.suhoorTextSecondary)

                            HStack(spacing: 12) {
                                TextField("Pages", text: $pagesInput)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)

                                Button("Update") {
                                    if let pages = Int(pagesInput) {
                                        readingService.updatePagesRead(day: day, pages: pages)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.suhoorGold)
                            }

                            Button {
                                readingService.markDayComplete(day: day)
                            } label: {
                                Label("Mark Complete", systemImage: "checkmark.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding()
                        .background(Color.suhoorSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding()
                }
            }
            .navigationTitle("Day \(day)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        stopTimer()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            pagesInput = "\(reading?.pagesRead ?? 0)"
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Timer

    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        stopTimer()
        elapsedSeconds = 0
    }

    // MARK: - External App Deeplink

    private func openQuranApp() {
        // Try common Quran app deeplinks, fall back to web
        let deeplinks = [
            "quran://juz/\(reading?.juz ?? 1)",
            "https://quran.com/juz/\(reading?.juz ?? 1)"
        ]

        for link in deeplinks {
            if let url = URL(string: link) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    return
                }
            }
        }

        // Fallback to web
        if let url = URL(string: "https://quran.com/juz/\(reading?.juz ?? 1)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ReadingSessionView(day: 5, readingService: QuranReadingService.shared)
}
