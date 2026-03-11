import Foundation
import Combine

@MainActor
final class SehriChecklistService: ObservableObject {
    static let shared = SehriChecklistService()
    
    @Published var todayChecklist: DailyChecklistData
    @Published var customItems: [ChecklistItem] = []
    
    private static let checklistKey = "sehri_checklist_data"
    private static let customItemsKey = "sehri_custom_items"
    private static let suiteName = "group.com.chadnewbry.suhoor"
    
    private init() {
        let todayKey = DailyChecklistData.dateKey(for: Date())
        self.todayChecklist = DailyChecklistData(dateKey: todayKey, items: ChecklistItem.defaults)
        loadData()
    }
    
    func toggleItem(_ item: ChecklistItem) {
        if let idx = todayChecklist.items.firstIndex(where: { $0.id == item.id }) {
            todayChecklist.items[idx].isCompleted.toggle()
            saveData()
        }
    }
    
    func addCustomItem(title: String, minutesBefore: Int = 30) {
        let item = ChecklistItem(title: title, minutesBefore: minutesBefore, isDefault: false)
        todayChecklist.items.append(item)
        customItems.append(item)
        saveData()
        saveCustomItems()
    }
    
    func removeItem(_ item: ChecklistItem) {
        guard !item.isDefault else { return }
        todayChecklist.items.removeAll { $0.id == item.id }
        customItems.removeAll { $0.title == item.title }
        saveData()
        saveCustomItems()
    }
    
    func scheduleChecklistAlerts(sehriTime: Date) async {
        let service = NotificationService.shared
        for item in todayChecklist.items where !item.isCompleted {
            let alertTime = sehriTime.addingTimeInterval(-Double(item.minutesBefore) * 60)
            guard alertTime > Date() else { continue }
            await service.scheduleNotification(
                id: "checklist_\(item.id.uuidString)",
                title: "📋 Sehri Reminder",
                body: item.title,
                date: alertTime
            )
        }
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        let todayKey = DailyChecklistData.dateKey(for: Date())
        
        // Load custom items
        if let data = UserDefaults(suiteName: Self.suiteName)?.data(forKey: Self.customItemsKey),
           let items = try? JSONDecoder().decode([ChecklistItem].self, from: data) {
            customItems = items
        }
        
        // Load today's checklist or create fresh
        if let data = UserDefaults(suiteName: Self.suiteName)?.data(forKey: Self.checklistKey),
           let stored = try? JSONDecoder().decode(DailyChecklistData.self, from: data),
           stored.dateKey == todayKey {
            todayChecklist = stored
        } else {
            // Reset for new day — combine defaults + custom
            var items = ChecklistItem.defaults
            for custom in customItems {
                items.append(ChecklistItem(title: custom.title, minutesBefore: custom.minutesBefore, isDefault: false))
            }
            todayChecklist = DailyChecklistData(dateKey: todayKey, items: items)
            saveData()
        }
    }
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(todayChecklist) {
            UserDefaults(suiteName: Self.suiteName)?.set(data, forKey: Self.checklistKey)
        }
    }
    
    private func saveCustomItems() {
        if let data = try? JSONEncoder().encode(customItems) {
            UserDefaults(suiteName: Self.suiteName)?.set(data, forKey: Self.customItemsKey)
        }
    }
}
