import SwiftUI

// MARK: - App Constants
enum AppConstants {
    static let appName = "Daily Routine"
    static let appVersion = "1.0.0"
    
    // Animation
    static let defaultAnimation: Animation = .spring(response: 0.35, dampingFraction: 0.8)
    static let quickAnimation: Animation = .easeInOut(duration: 0.2)
    
    // Layout
    static let cornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
    
    // Timer
    static let timerInterval: TimeInterval = 1.0
}

// MARK: - Activity Type
enum ActivityType: String, CaseIterable, Codable {
    case sleep = "Sleep"
    case morningRoutine = "Morning Routine"
    case gym = "Gym / Running"
    case em = "EM"
    case commute = "Commute"
    case work = "Work"
    case lunch = "Work / Lunch"
    case freelancer = "Freelancer"
    case masterDegree = "Master Degree"
    case ncpGenAI = "NCP GenAI"
    case hsk = "HSK"
    case eveningRoutine = "Evening Routine"
    case dinner = "Dinner"
    case consoleRelax = "Console / Relax"
    case billiards = "Billiards"
    case freeTime = "Free Time"
    case lunchRest = "Lunch / Rest"
    case freeSocial = "Free / Social"
    case breakTime = "Break"
    
    var color: Color {
        switch self {
        case .sleep: return Color(hex: "5856D6")
        case .work, .lunch: return Color(hex: "007AFF")
        case .freelancer: return Color(hex: "FF9500")
        case .masterDegree: return Color(hex: "AF52DE")
        case .ncpGenAI: return Color(hex: "FF2D55")
        case .hsk: return Color(hex: "5AC8FA")
        case .gym: return Color(hex: "34C759")
        case .em: return Color(hex: "FFCC00")
        case .commute: return Color(hex: "8E8E93")
        case .consoleRelax: return Color(hex: "30B0C7")
        case .billiards: return Color(hex: "FF6482")
        case .morningRoutine, .eveningRoutine: return Color(hex: "AC8E68")
        case .dinner, .lunchRest: return Color(hex: "FF6B6B")
        case .freeTime, .freeSocial: return Color(hex: "64D2FF")
        case .breakTime: return Color(hex: "A8D8EA")
        }
    }
    
    var icon: String {
        switch self {
        case .sleep: return "moon.fill"
        case .morningRoutine, .eveningRoutine: return "sparkles"
        case .gym: return "figure.run"
        case .em: return "book.fill"
        case .commute: return "car.fill"
        case .work, .lunch: return "briefcase.fill"
        case .freelancer: return "laptopcomputer"
        case .masterDegree: return "graduationcap.fill"
        case .ncpGenAI: return "brain.head.profile"
        case .hsk: return "character.book.closed.fill"
        case .consoleRelax: return "gamecontroller.fill"
        case .billiards: return "circle.fill"
        case .dinner, .lunchRest: return "fork.knife"
        case .freeTime, .freeSocial: return "person.2.fill"
        case .breakTime: return "cup.and.saucer.fill"
        }
    }
    
    var category: ActivityCategoryType {
        switch self {
        case .work, .lunch: return .work
        case .freelancer: return .work
        case .masterDegree, .ncpGenAI, .hsk, .em: return .study
        case .gym: return .fitness
        case .billiards, .freeTime, .freeSocial: return .relationship
        case .consoleRelax, .breakTime: return .relax
        case .commute: return .commute
        case .sleep: return .relax
        case .morningRoutine, .eveningRoutine: return .relax
        case .dinner, .lunchRest: return .relax
        }
    }
    
    var localizedKey: String {
        return "activity_\(self.rawValue.lowercased().replacingOccurrences(of: " / ", with: "_").replacingOccurrences(of: " ", with: "_"))"
    }
}

// MARK: - Activity Category Type
enum ActivityCategoryType: String, CaseIterable, Codable {
    case work = "Work"
    case study = "Study"
    case fitness = "Fitness"
    case relationship = "Relationship"
    case relax = "Relax"
    case commute = "Commute"
    
    var color: Color {
        switch self {
        case .work: return Color(hex: "007AFF")
        case .study: return Color(hex: "AF52DE")
        case .fitness: return Color(hex: "34C759")
        case .relationship: return Color(hex: "FF6482")
        case .relax: return Color(hex: "30B0C7")
        case .commute: return Color(hex: "8E8E93")
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .fitness: return "figure.run"
        case .relationship: return "person.2.fill"
        case .relax: return "leaf.fill"
        case .commute: return "car.fill"
        }
    }
}

// MARK: - Day of Week
enum DayOfWeek: Int, CaseIterable, Codable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
    
    var isWeekday: Bool {
        return self != .saturday && self != .sunday
    }
    
    static func from(date: Date) -> DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: date)
        return DayOfWeek(rawValue: weekday) ?? .monday
    }
}

// MARK: - Completion Status
enum CompletionStatus: String, Codable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case skipped = "skipped"
    case overdue = "overdue"
    
    var color: Color {
        switch self {
        case .pending: return .secondary
        case .inProgress: return Color(hex: "007AFF")
        case .completed: return Color(hex: "34C759")
        case .skipped: return Color(hex: "8E8E93")
        case .overdue: return Color(hex: "FF453A")
        }
    }
}
