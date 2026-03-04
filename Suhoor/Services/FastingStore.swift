import Foundation
import SwiftUI
import Observation

@Observable
final class FastingStore {
    var days: [FastingDay]
    var menstrualModeEnabled: Bool {
        didSet { save() }
    }
    
    private let key = "suhoor_fasting_days"
    private let menstrualKey = "suhoor_menstrual_mode"
    
    init() {
        menstrualModeEnabled = UserDefaults.standard.bool(forKey: menstrualKey)
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([FastingDay].self, from: data) {
            days = decoded
        } else {
            days = (1...30).map { FastingDay(id: $0) }
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(days) {
            UserDefaults.standard.set(data, forKey: key)
        }
        UserDefaults.standard.set(menstrualModeEnabled, forKey: menstrualKey)
    }
    
    func updateDay(_ dayNumber: Int, status: FastingStatus, reason: ExcuseReason? = nil, notes: String = "", sehriTime: Date? = nil, iftarTime: Date? = nil) {
        guard let idx = days.firstIndex(where: { $0.id == dayNumber }) else { return }
        days[idx].status = status
        days[idx].excuseReason = reason
        days[idx].notes = notes
        days[idx].sehriTime = sehriTime
        days[idx].iftarTime = iftarTime
        save()
        
        if status == .fasted, let sehri = sehriTime, let iftar = iftarTime {
            HealthKitService.shared.writeFastingData(start: sehri, end: iftar)
        }
    }
    
    func toggleMadeUp(_ dayNumber: Int) {
        guard let idx = days.firstIndex(where: { $0.id == dayNumber }) else { return }
        days[idx].madeUp.toggle()
        save()
    }
    
    func markPeriodDays(from startDay: Int, count: Int) {
        for day in startDay..<min(startDay + count, 31) {
            guard let idx = days.firstIndex(where: { $0.id == day }) else { continue }
            days[idx].status = .excused
            days[idx].excuseReason = .menstruation
        }
        save()
    }
    
    // MARK: - Computed Stats
    
    var totalFasted: Int {
        days.filter { $0.status == .fasted }.count
    }
    
    var currentStreak: Int {
        var streak = 0
        // Count backwards from the latest fasted day
        for day in days.reversed() {
            if day.status == .fasted {
                streak += 1
            } else if day.status != .future {
                break
            }
        }
        return streak
    }
    
    var longestStreak: Int {
        var longest = 0
        var current = 0
        for day in days {
            if day.status == .fasted {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }
    
    var makeupFasts: [FastingDay] {
        days.filter { $0.needsMakeup }
    }
    
    var remainingMakeupCount: Int {
        makeupFasts.count
    }
    
    func ashraCompletion(_ ashra: Ashra) -> Double {
        let range = ashra.dayRange
        let relevant = days.filter { range.contains($0.id) }
        let fasted = relevant.filter { $0.status == .fasted }.count
        return Double(fasted) / Double(range.count)
    }
    
    // Today = day number in Ramadan (1-based). For demo, use day 8.
    var currentDayNumber: Int {
        // In production, calculate from Ramadan start date
        // For now, return a reasonable default
        let calendar = Calendar.current
        // Ramadan 2026 starts approximately Feb 18, 2026
        let components = DateComponents(year: 2026, month: 2, day: 18)
        guard let ramadanStart = calendar.date(from: components) else { return 1 }
        let daysSinceStart = calendar.dateComponents([.day], from: ramadanStart, to: Date()).day ?? 0
        let dayNumber = daysSinceStart + 1
        return max(1, min(30, dayNumber))
    }
    
    var milestoneReached: Int? {
        let milestones = [30, 21, 15, 7]
        let streak = currentStreak
        return milestones.first { streak >= $0 }
    }
}
