import SwiftUI

struct PrayerTimesView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showNearbyMosques = false
    @GestureState private var dragOffset: CGFloat = 0

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        ZStack {
            Color.suhoorIndigo.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    dateHeader
                    sehriIftarCard
                    prayerListCard
                    if viewModel.isRamadan {
                        taraweehCard
                    }
                    QiblaCompassView()
                    nearbyMosquesButton
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 80 {
                        withAnimation { viewModel.navigateDay(by: -1) }
                    } else if value.translation.width < -80 {
                        withAnimation { viewModel.navigateDay(by: 1) }
                    }
                }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Prayer Times")
                    .font(.headline)
                    .foregroundStyle(Color.suhoorTextPrimary)
            }
        }
        .sheet(isPresented: $showNearbyMosques) {
            NearbyMosquesView()
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        VStack(spacing: 6) {
            HStack {
                Button { withAnimation { viewModel.navigateDay(by: -1) } } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.suhoorGold)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(viewModel.hijriDateString)
                        .font(.headline)
                        .foregroundStyle(Color.suhoorGold)
                    Text(viewModel.gregorianDateString)
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }

                Spacer()

                Button { withAnimation { viewModel.navigateDay(by: 1) } } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.suhoorGold)
                }
            }

            if !viewModel.isToday {
                Button {
                    withAnimation {
                        viewModel.selectedDate = Date()
                        viewModel.recalculate()
                    }
                } label: {
                    Text("Today")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.suhoorIndigo)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.suhoorGold, in: Capsule())
                }
            }
        }
        .padding(.top, 12)
    }

    // MARK: - Sehri / Iftar Prominent Card

    private var sehriIftarCard: some View {
        HStack(spacing: 16) {
            prominentTimeBlock(
                label: "Sehri (Imsak)",
                time: viewModel.imsakTime,
                icon: "moon.haze"
            )
            Rectangle()
                .fill(Color.suhoorDivider)
                .frame(width: 1, height: 50)
            prominentTimeBlock(
                label: "Iftar",
                time: viewModel.iftarTime,
                icon: "sunset"
            )
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.suhoorGold.opacity(0.15), Color.suhoorGold.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.suhoorGold.opacity(0.2), lineWidth: 1)
        )
    }

    private func prominentTimeBlock(label: String, time: Date?, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.suhoorGold)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.suhoorTextSecondary)
            if let time {
                Text(timeFormatter.string(from: time))
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.suhoorGold)
            } else {
                Text("--:--")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Prayer List

    private var prayerListCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.allPrayers.enumerated()), id: \.element.id) { index, prayer in
                let isNext = prayer.id == viewModel.nextPrayer?.id
                let isPast = viewModel.isToday && prayer.time <= viewModel.now

                HStack(spacing: 14) {
                    Image(systemName: prayer.name.systemImage)
                        .font(.body)
                        .foregroundStyle(isNext ? Color.suhoorGold : Color.suhoorTextSecondary)
                        .frame(width: 28)

                    Text(prayer.name.rawValue)
                        .font(.subheadline.weight(isNext ? .semibold : .regular))
                        .foregroundStyle(isNext ? Color.suhoorTextPrimary : Color.suhoorTextSecondary)

                    Spacer()

                    if isNext {
                        Text(prayer.countdown(from: viewModel.now))
                            .font(.caption.weight(.medium).monospacedDigit())
                            .foregroundStyle(Color.suhoorGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.suhoorGold.opacity(0.12), in: Capsule())
                    }

                    Text(timeFormatter.string(from: prayer.time))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(isNext ? Color.suhoorGold : Color.suhoorTextSecondary)

                    Button { viewModel.toggleAzan(for: prayer.name) } label: {
                        Image(systemName: viewModel.isAzanEnabled(for: prayer.name) ? "bell.fill" : "bell.slash")
                            .font(.caption)
                            .foregroundStyle(
                                viewModel.isAzanEnabled(for: prayer.name) ? Color.suhoorGold : Color.suhoorTextSecondary.opacity(0.5)
                            )
                    }
                    .buttonStyle(.plain)

                    if isPast {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.suhoorSuccess)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isNext ? Color.suhoorGold.opacity(0.06) : .clear)

                if index < viewModel.allPrayers.count - 1 {
                    Divider().background(Color.suhoorDivider).padding(.leading, 58)
                }
            }
        }
        .background(Color.suhoorSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Taraweeh

    private var taraweehCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.body)
                .foregroundStyle(Color.suhoorAmber)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text("Taraweeh")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.suhoorTextPrimary)
                Text("After Isha prayer")
                    .font(.caption2)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }

            Spacer()

            if let time = viewModel.taraweehTime {
                Text(timeFormatter.string(from: time))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.suhoorAmber)
            }
        }
        .padding(16)
        .background(Color.suhoorAmber.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.suhoorAmber.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Nearby Mosques

    private var nearbyMosquesButton: some View {
        Button { showNearbyMosques = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.body)
                    .foregroundStyle(Color.suhoorGold)
                Text("Nearby Mosques")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.suhoorTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
            .padding(16)
            .background(Color.suhoorSurface, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PrayerTimesView()
    }
    .preferredColorScheme(.dark)
}
