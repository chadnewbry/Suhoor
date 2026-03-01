import Foundation
import HealthKit

@Observable
final class HealthKitService {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()

    var isAuthorized = false

    private init() {}

    // MARK: - Authorization

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isAvailable else { return }

        var typesToWrite: Set<HKSampleType> = []

        // Intermittent fasting category (iOS 16+)
        if let fastingType = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding) {
            // Note: Apple doesn't expose a dedicated "intermittent fasting" type yet.
            // We use dietaryEnergyConsumed as a workaround to record fasting windows,
            // or fall back to a custom workout category.
            _ = fastingType  // placeholder
        }

        // Use dietary energy consumed = 0 as a fasting marker
        if let energyType = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) {
            typesToWrite.insert(energyType)
        }

        try await healthStore.requestAuthorization(toShare: typesToWrite, read: [])
        isAuthorized = true
    }

    // MARK: - Save Fasting Data

    /// Saves a completed fast as a zero-calorie dietary energy sample spanning
    /// the fasting window — this is how health-tracking apps represent
    /// intermittent fasting in Apple Health.
    func saveFastingRecord(_ record: FastingRecord) async throws {
        guard isAvailable, record.status == .fasted else { return }
        guard let energyType = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) else { return }

        let sample = HKQuantitySample(
            type: energyType,
            quantity: HKQuantity(unit: .kilocalorie(), doubleValue: 0),
            start: record.fastStartTime,
            end: record.fastEndTime,
            metadata: [
                "SuhoorFastingDay": record.dayNumber,
                "SuhoorRamadanYear": record.ramadanYear,
                "SuhoorFastDurationHours": record.fastDurationHours,
            ]
        )

        try await healthStore.save(sample)
    }

    // MARK: - Sync Historical Data

    func syncHistoricalFasts(_ records: [FastingRecord]) async throws {
        guard isAvailable else { return }
        for record in records where record.status == .fasted {
            try await saveFastingRecord(record)
        }
    }
}
