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

        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        try await healthStore.requestAuthorization(toShare: typesToWrite, read: [])
        isAuthorized = true
    }

    // MARK: - Save Fasting Data

    /// Saves a completed fast as a sleep analysis category sample (maps to intermittent fasting).
    func saveFastingRecord(_ record: FastingRecord) async throws {
        guard isAvailable, record.status == .fasted else { return }

        let categoryType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sample = HKCategorySample(
            type: categoryType,
            value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            start: record.fastStartTime,
            end: record.fastEndTime,
            metadata: [
                HKMetadataKeyWasTakenInLab: false,
                "SuhoorFastingDay": record.dayNumber
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
