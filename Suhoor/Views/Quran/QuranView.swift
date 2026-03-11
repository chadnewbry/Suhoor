import SwiftUI

struct QuranView: View {
    @StateObject private var readingService = QuranReadingService.shared
    @State private var selectedDay: Int?

    var body: some View {
        ZStack {
            Color.suhoorIndigo.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Khatam Progress
                    khatamProgressCard

                    // MARK: - Daily Juz Grid
                    dailyJuzSection
                }
                .padding()
            }
        }
        .navigationTitle("Quran")
    }

    // MARK: - Khatam Progress Card

    private var khatamProgressCard: some View {
        VStack(spacing: 12) {
            Text("Khatam Progress")
                .font(.headline)
                .foregroundStyle(Color.suhoorTextPrimary)

            ZStack {
                Circle()
                    .stroke(Color.suhoorTextSecondary.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: readingService.progress.khatamPercentage)
                    .stroke(Color.suhoorGold, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: readingService.progress.khatamPercentage)

                VStack(spacing: 4) {
                    Text("\(Int(readingService.progress.khatamPercentage * 100))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Text("\(readingService.progress.completedJuz)/30 Juz")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }
            .frame(width: 160, height: 160)

            if let estimated = readingService.progress.estimatedCompletionDate {
                Text("Est. completion: \(estimated, style: .date)")
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
        }
        .padding()
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Daily Juz Section

    private var dailyJuzSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("30-Day Reading Plan")
                .font(.headline)
                .foregroundStyle(Color.suhoorTextPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(readingService.progress.dailyReadings) { reading in
                    DayJuzCell(reading: reading, isToday: reading.day == readingService.progress.currentDay)
                        .onTapGesture {
                            selectedDay = reading.day
                        }
                }
            }
        }
        .sheet(item: $selectedDay) { day in
            JuzDetailSheet(day: day, readingService: readingService)
        }
    }
}

// MARK: - Day Juz Cell

private struct DayJuzCell: View {
    let reading: DailyReading
    let isToday: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("Day \(reading.day)")
                .font(.caption2)
                .foregroundStyle(Color.suhoorTextSecondary)
            Text("Juz \(reading.juz)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.suhoorTextPrimary)

            if reading.isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.green)
                    .font(.caption)
            } else {
                ProgressView(value: reading.completionPercentage)
                    .tint(Color.suhoorGold)
            }
        }
        .padding(8)
        .background(isToday ? Color.suhoorGold.opacity(0.2) : Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.suhoorGold : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Juz Detail Sheet

private struct JuzDetailSheet: View {
    let day: Int
    @ObservedObject var readingService: QuranReadingService
    @Environment(\.dismiss) private var dismiss
    @State private var pagesInput: String = ""

    private var reading: DailyReading? {
        readingService.progress.dailyReadings.first { $0.day == day }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()

                VStack(spacing: 20) {
                    if let reading {
                        if let juz = readingService.juzInfo(for: reading.juz) {
                            VStack(spacing: 8) {
                                Text("Juz \(juz.juz)")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Color.suhoorTextPrimary)
                                Text("\(juz.startSurah) \(juz.startAyah) — \(juz.endSurah) \(juz.endAyah)")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.suhoorTextSecondary)
                            }
                        }

                        VStack(spacing: 8) {
                            Text("Pages Read: \(reading.pagesRead)/\(reading.totalPages)")
                                .foregroundStyle(Color.suhoorTextPrimary)

                            ProgressView(value: reading.completionPercentage)
                                .tint(Color.suhoorGold)
                                .scaleEffect(y: 2)
                        }
                        .padding()

                        HStack(spacing: 12) {
                            TextField("Pages", text: $pagesInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)

                            Button("Update") {
                                if let pages = Int(pagesInput) {
                                    readingService.updatePagesRead(day: day, pages: pages)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.suhoorGold)
                        }

                        Button("Mark Complete") {
                            readingService.markDayComplete(day: day)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Day \(day)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            pagesInput = "\(reading?.pagesRead ?? 0)"
        }
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    NavigationStack {
        QuranView()
    }
}
