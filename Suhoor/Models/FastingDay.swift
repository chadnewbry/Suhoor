import Foundation

enum FastingStatus: String, Codable, CaseIterable {
    case fasted
    case missed
    case excused
    case future
    case unknown
}

enum ExcuseReason: String, Codable, CaseIterable, Identifiable {
    case menstruation = "Menstruation"
    case travel = "Travel"
    case illness = "Illness"
    case other = "Other"
    
    var id: String { rawValue }
}

struct FastingDay: Identifiable, Codable {
    var id: Int // Day number 1-30
    var status: FastingStatus
    var excuseReason: ExcuseReason?
    var notes: String
    var madeUp: Bool
    var sehriTime: Date?
    var iftarTime: Date?
    
    init(id: Int, status: FastingStatus = .future, excuseReason: ExcuseReason? = nil, notes: String = "", madeUp: Bool = false, sehriTime: Date? = nil, iftarTime: Date? = nil) {
        self.id = id
        self.status = status
        self.excuseReason = excuseReason
        self.notes = notes
        self.madeUp = madeUp
        self.sehriTime = sehriTime
        self.iftarTime = iftarTime
    }
    
    var needsMakeup: Bool {
        (status == .missed || status == .excused) && !madeUp
    }
}

enum Ashra: Int, CaseIterable, Identifiable {
    case mercy = 1
    case forgiveness = 2
    case freedomFromFire = 3
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .mercy: "Mercy"
        case .forgiveness: "Forgiveness"
        case .freedomFromFire: "Freedom from Fire"
        }
    }
    
    var dayRange: ClosedRange<Int> {
        switch self {
        case .mercy: 1...10
        case .forgiveness: 11...20
        case .freedomFromFire: 21...30
        }
    }
    
    var dua: String {
        switch self {
        case .mercy:
            "رَبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ"
        case .forgiveness:
            "أَسْتَغْفِرُ اللهَ رَبِّي مِنْ كُلِّ ذَنْبٍ وَأَتُوبُ إِلَيْهِ"
        case .freedomFromFire:
            "اللَّهُمَّ أَجِرْنِي مِنَ النَّارِ"
        }
    }
    
    var duaTranslation: String {
        switch self {
        case .mercy:
            "My Lord, forgive and have mercy, and You are the best of the merciful."
        case .forgiveness:
            "I seek forgiveness from Allah, my Lord, from every sin and I repent to Him."
        case .freedomFromFire:
            "O Allah, save me from the Hellfire."
        }
    }
}

#if DEBUG
protocol PreviewData {
    static var preview: Self { get }
    static var previewList: [Self] { get }
}

extension FastingDay: PreviewData {
    static var preview: FastingDay {
        FastingDay(id: 1, status: .fasted,
                   sehriTime: Calendar.current.date(bySettingHour: 4, minute: 30, second: 0, of: Date()),
                   iftarTime: Calendar.current.date(bySettingHour: 18, minute: 15, second: 0, of: Date()))
    }
    
    static var previewList: [FastingDay] {
        (1...30).map { day in
            if day <= 5 {
                FastingDay(id: day, status: .fasted)
            } else if day == 6 {
                FastingDay(id: day, status: .excused, excuseReason: .illness)
            } else if day == 7 {
                FastingDay(id: day, status: .missed)
            } else {
                FastingDay(id: day, status: .future)
            }
        }
    }
}
#endif
