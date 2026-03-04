import Foundation
import HealthKit

final class HealthKitService {
    static let shared = HealthKitService()
    private let store = HKHealthStore()
    
    private init() {}
    
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() {
        guard isAvailable else { return }
        
        // iOS 16+ has HKCategoryTypeIdentifier.intermittentFasting, but we use
        // a dietary energy category approach for broader compatibility.
        // For HealthKit fasting, we write a category sample.
        guard let fastingType = HKObjectType.categoryType(forIdentifier: .intermittentFasting) else { return }
        
        store.requestAuthorization(toShare: [fastingType], read: [fastingType]) { _, _ in }
    }
    
    func writeFastingData(start: Date, end: Date) {
        guard isAvailable else { return }
        guard let fastingType = HKObjectType.categoryType(forIdentifier: .intermittentFasting) else { return }
        
        let sample = HKCategorySample(
            type: fastingType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        
        store.save(sample) { _, error in
            if let error {
                print("HealthKit save error: \(error.localizedDescription)")
            }
        }
    }
}
