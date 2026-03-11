import Foundation
import Combine

@MainActor
final class HydrationService: ObservableObject {
    static let shared = HydrationService()
    
    @Published var todayEntry: HydrationEntry
    @Published var weeklyHistory: [HydrationEntry] = []
    
    private static let storageKey = "hydration_data"
    private static let suiteName = "group.com.chadnewbry.suhoor"
    
    private init() {
        let today = HydrationEntry()
        self.todayEntry = today
        loadData()
    }
    
    var isHydrationWindowActive: Bool {
        // Hydration only between iftar and sehri
        // Check SharedData for times; default to always active if unavailable
        guard let shared = SharedData.load() else { return true }
        let now = Date()
        // Between iftar and midnight, or between midnight and sehri
        return now >= shared.iftarTime || now <= shared.sehriTime
    }
    
    func logGlass() {
        guard todayEntry.glasses < todayEntry.target * 2 else { return } // reasonable cap
        todayEntry.glasses += 1
        saveData()
    }
    
    func setTarget(_ target: Int) {
        todayEntry.target = max(1, min(target, 20))
        saveData()
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        guard let data = UserDefaults(suiteName: Self.suiteName)?.data(forKey: Self.storageKey),
              let entries = try? JSONDecoder().decode([HydrationEntry].self, from: data) else {
            todayEntry = HydrationEntry()
            weeklyHistory = []
            return
        }
        
        let todayKey = Calendar.current.startOfDay(for: Date())
        if let existing = entries.first(where: { $0.date == todayKey }) {
            todayEntry = existing
        } else {
            todayEntry = HydrationEntry()
        }
        
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        weeklyHistory = entries
            .filter { $0.date >= Calendar.current.startOfDay(for: weekAgo) && $0.date < todayKey }
            .sorted { $0.date < $1.date }
    }
    
    private func saveData() {
        var entries = loadAllEntries()
        let todayKey = Calendar.current.startOfDay(for: Date())
        entries.removeAll { $0.date == todayKey }
        entries.append(todayEntry)
        
        // Keep last 30 days
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        entries = entries.filter { $0.date >= Calendar.current.startOfDay(for: cutoff) }
        
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults(suiteName: Self.suiteName)?.set(data, forKey: Self.storageKey)
        }
        
        // Refresh weekly history
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        weeklyHistory = entries
            .filter { $0.date >= Calendar.current.startOfDay(for: weekAgo) && $0.date < todayKey }
            .sorted { $0.date < $1.date }
    }
    
    private func loadAllEntries() -> [HydrationEntry] {
        guard let data = UserDefaults(suiteName: Self.suiteName)?.data(forKey: Self.storageKey),
              let entries = try? JSONDecoder().decode([HydrationEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func scheduleHydrationReminders(iftarTime: Date, sehriTime: Date) async {
        let service = NotificationService.shared
        // Schedule reminders every 30 min between iftar and sehri
        var reminderTime = iftarTime.addingTimeInterval(30 * 60) // 30 min after iftar
        var index = 0
        while reminderTime < sehriTime {
            await service.scheduleNotification(
                id: "hydration_reminder_\(index)",
                title: "💧 Stay Hydrated",
                body: "Remember to drink water! You've had \(todayEntry.glasses) of \(todayEntry.target) glasses.",
                date: reminderTime
            )
            reminderTime = reminderTime.addingTimeInterval(30 * 60)
            index += 1
        }
    }
}
