import Foundation
import HealthKit

final class HealthKitService {
    static let shared = HealthKitService()
    private let store = HKHealthStore()

    private init() {}

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    private(set) var isAuthorized: Bool = false

    func requestAuthorization() {
        guard isAvailable else { return }
        // Use mindful session as a proxy for fasting periods
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }

        store.requestAuthorization(toShare: [mindfulType], read: [mindfulType]) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = success
            }
        }
    }

    func writeFastingData(start: Date, end: Date) {
        guard isAvailable else { return }
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }

        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end,
            metadata: ["SuhoorFastingSession": true]
        )

        store.save(sample) { _, error in
            if let error {
                print("HealthKit save error: \(error.localizedDescription)")
            }
        }
    }
}
