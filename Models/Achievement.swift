import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var title: String
    var achievementDescription: String
    var icon: String
    var unlockedAt: Date?
    var category: String
    var requirement: Double // e.g., 7 for "7-day streak"
    var currentProgress: Double
    
    init(
        title: String,
        description: String,
        icon: String,
        category: String,
        requirement: Double
    ) {
        self.id = UUID()
        self.title = title
        self.achievementDescription = description
        self.icon = icon
        self.category = category
        self.requirement = requirement
        self.currentProgress = 0
        self.unlockedAt = nil
    }
    
    var isUnlocked: Bool { unlockedAt != nil }
    
    var progress: Double {
        guard requirement > 0 else { return 0 }
        return min(currentProgress / requirement, 1.0)
    }
    
    func unlock() {
        if unlockedAt == nil {
            unlockedAt = Date()
            currentProgress = requirement
        }
    }
}

// MARK: - Achievement Definitions
enum AchievementDefinition: CaseIterable {
    case firstCheckIn, weekStreak, monthStreak, earlyBird, nightOwl
    case workaholic, fitnessFreak, polyglot, allRounder, perfectDay
    case calorieTracker, evidenceCollector, goalSetter, consistent, speedDemon
    
    var title: String {
        switch self {
        case .firstCheckIn: return "First Step"
        case .weekStreak: return "Week Warrior"
        case .monthStreak: return "Month Master"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .workaholic: return "Workaholic"
        case .fitnessFreak: return "Fitness Freak"
        case .polyglot: return "Polyglot"
        case .allRounder: return "All-Rounder"
        case .perfectDay: return "Perfect Day"
        case .calorieTracker: return "Calorie Counter"
        case .evidenceCollector: return "Proof Master"
        case .goalSetter: return "Goal Setter"
        case .consistent: return "Consistency King"
        case .speedDemon: return "Speed Demon"
        }
    }
    
    var description: String {
        switch self {
        case .firstCheckIn: return "Complete your first activity check-in"
        case .weekStreak: return "Maintain a 7-day completion streak"
        case .monthStreak: return "Maintain a 30-day completion streak"
        case .earlyBird: return "Check in before 6 AM 5 times"
        case .nightOwl: return "Complete activities after 10 PM 5 times"
        case .workaholic: return "Log 100 hours of work"
        case .fitnessFreak: return "Complete 30 gym sessions"
        case .polyglot: return "Study HSK for 50 hours"
        case .allRounder: return "Complete all activity types at least once"
        case .perfectDay: return "Complete 100% of daily activities"
        case .calorieTracker: return "Log 30 calorie entries"
        case .evidenceCollector: return "Capture 10 evidence photos"
        case .goalSetter: return "Create and complete 3 goals"
        case .consistent: return "Achieve 80%+ completion for 14 days"
        case .speedDemon: return "Complete an activity in less than planned time"
        }
    }
    
    var icon: String {
        switch self {
        case .firstCheckIn: return "star.fill"
        case .weekStreak: return "flame.fill"
        case .monthStreak: return "crown.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .workaholic: return "briefcase.fill"
        case .fitnessFreak: return "figure.run"
        case .polyglot: return "character.book.closed.fill"
        case .allRounder: return "circle.grid.3x3.fill"
        case .perfectDay: return "checkmark.seal.fill"
        case .calorieTracker: return "flame.fill"
        case .evidenceCollector: return "camera.fill"
        case .goalSetter: return "target"
        case .consistent: return "chart.line.uptrend.xyaxis"
        case .speedDemon: return "bolt.fill"
        }
    }
    
    var category: String {
        switch self {
        case .firstCheckIn, .perfectDay, .allRounder: return "general"
        case .weekStreak, .monthStreak, .consistent: return "streak"
        case .earlyBird, .nightOwl, .speedDemon: return "time"
        case .workaholic, .fitnessFreak, .polyglot: return "activity"
        case .calorieTracker, .evidenceCollector, .goalSetter: return "tracking"
        }
    }
    
    var requirement: Double {
        switch self {
        case .firstCheckIn: return 1
        case .weekStreak: return 7
        case .monthStreak: return 30
        case .earlyBird: return 5
        case .nightOwl: return 5
        case .workaholic: return 100
        case .fitnessFreak: return 30
        case .polyglot: return 50
        case .allRounder: return Double(ActivityType.allCases.count)
        case .perfectDay: return 1
        case .calorieTracker: return 30
        case .evidenceCollector: return 10
        case .goalSetter: return 3
        case .consistent: return 14
        case .speedDemon: return 1
        }
    }
}
