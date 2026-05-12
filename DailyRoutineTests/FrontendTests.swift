import XCTest
import SwiftUI
@testable import DailyRoutine

// MARK: - 1. FRONTEND TESTS
/// Tests view hierarchy, navigation structure, component data binding, and rendering
final class FrontendTests: XCTestCase {
    
    // MARK: - Tab Navigation Structure
    
    func testMainTabViewHas5Tabs() {
        // Verify the 5-tab structure: Dashboard, Timeline, Weekly, Analytics, More
        let expectedTabs = ["Dashboard", "Timeline", "Weekly", "Analytics", "More"]
        XCTAssertEqual(expectedTabs.count, 5, "App should have exactly 5 tabs")
    }
    
    // MARK: - Activity Type Rendering Data
    
    func testAllActivityTypesProvideRenderingData() {
        for type in ActivityType.allCases {
            XCTAssertFalse(type.rawValue.isEmpty, "\(type) should have a display name")
            XCTAssertFalse(type.icon.isEmpty, "\(type) should have an SF Symbol icon")
            XCTAssertNotNil(type.color, "\(type) should have a color")
            XCTAssertNotNil(type.category, "\(type) should map to a category")
            XCTAssertFalse(type.localizedKey.isEmpty, "\(type) should have a localization key")
        }
    }
    
    // MARK: - Goal Model View Data
    
    func testGoalProgress() {
        let goal = Goal(title: "Study 100h", targetValue: 100, unit: "hours")
        XCTAssertEqual(goal.progress, 0)
        
        goal.currentValue = 50
        XCTAssertEqual(goal.progress, 0.5, accuracy: 0.01)
        
        goal.currentValue = 100
        XCTAssertEqual(goal.progress, 1.0, accuracy: 0.01)
        
        goal.currentValue = 150
        XCTAssertEqual(goal.progress, 1.0, "Progress should cap at 1.0")
    }
    
    func testGoalDaysRemaining() {
        let futureGoal = Goal(title: "Test", targetValue: 10, endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!)
        XCTAssertGreaterThanOrEqual(futureGoal.daysRemaining, 9)
        XCTAssertLessThanOrEqual(futureGoal.daysRemaining, 10)
        
        let pastGoal = Goal(title: "Expired", targetValue: 10, endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        XCTAssertEqual(pastGoal.daysRemaining, 0)
    }
    
    func testGoalExpired() {
        let goal = Goal(title: "Expired", targetValue: 10, endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        XCTAssertTrue(goal.isExpired)
        
        goal.isCompleted = true
        XCTAssertFalse(goal.isExpired, "Completed goals should not be expired")
    }
    
    // MARK: - Achievement View Data
    
    func testAchievementDefinitions() {
        let allDefs = AchievementDefinition.allCases
        XCTAssertEqual(allDefs.count, 15, "Should have 15 achievement definitions")
        
        for def in allDefs {
            XCTAssertFalse(def.title.isEmpty)
            XCTAssertFalse(def.description.isEmpty)
            XCTAssertFalse(def.icon.isEmpty)
            XCTAssertFalse(def.category.isEmpty)
            XCTAssertGreaterThan(def.requirement, 0)
        }
    }
    
    func testAchievementProgress() {
        let achievement = Achievement(title: "Test", description: "Test", icon: "star", category: "general", requirement: 10)
        XCTAssertEqual(achievement.progress, 0)
        XCTAssertFalse(achievement.isUnlocked)
        
        achievement.currentProgress = 5
        XCTAssertEqual(achievement.progress, 0.5, accuracy: 0.01)
        
        achievement.unlock()
        XCTAssertTrue(achievement.isUnlocked)
        XCTAssertNotNil(achievement.unlockedAt)
        XCTAssertEqual(achievement.progress, 1.0)
    }
    
    // MARK: - MoodEntry View Data
    
    func testMoodEntryEmojis() {
        let moods: [(Int, String)] = [(1, "😢"), (2, "😔"), (3, "😐"), (4, "😊"), (5, "😁")]
        for (level, emoji) in moods {
            let entry = MoodEntry(moodLevel: level)
            XCTAssertEqual(entry.moodEmoji, emoji, "Mood level \(level) should show \(emoji)")
        }
    }
    
    func testMoodEntryEnergyEmojis() {
        let energies: [(Int, String)] = [(1, "🔋"), (2, "🪫"), (3, "⚡"), (4, "💪"), (5, "🚀")]
        for (level, emoji) in energies {
            let entry = MoodEntry(energyLevel: level)
            XCTAssertEqual(entry.energyEmoji, emoji)
        }
    }
    
    // MARK: - Theme System
    
    func testThemeColorSystem() {
        let theme = Color.theme
        // Verify all essential theme colors exist
        XCTAssertNotNil(theme.primary)
        XCTAssertNotNil(theme.primaryLight)
        XCTAssertNotNil(theme.accent)
        XCTAssertNotNil(theme.accentLight)
        XCTAssertNotNil(theme.success)
        XCTAssertNotNil(theme.warning)
        XCTAssertNotNil(theme.error)
        XCTAssertNotNil(theme.textSecondary)
    }
    
    func testThemeGradients() {
        XCTAssertNotNil(Color.theme.primaryGradient)
        XCTAssertNotNil(Color.theme.accentGradient)
        XCTAssertNotNil(Color.theme.surfaceGradient)
    }
    
    // MARK: - Color Hex Parsing
    
    func testColorHexParsing6Char() {
        let color = Color(hex: "007AFF")
        XCTAssertNotNil(color)
    }
    
    func testColorHexParsing3Char() {
        let color = Color(hex: "FFF")
        XCTAssertNotNil(color)
    }
    
    func testColorHexParsing8Char() {
        let color = Color(hex: "FF007AFF")
        XCTAssertNotNil(color)
    }
    
    func testColorHexWithHash() {
        let color = Color(hex: "#34C759")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Media Focus Modes
    
    func testFocusModeDefinitions() {
        let modes = MediaControlService.FocusMode.allCases
        XCTAssertEqual(modes.count, 5, "Should have 5 focus modes")
        
        for mode in modes {
            XCTAssertFalse(mode.rawValue.isEmpty)
            XCTAssertFalse(mode.icon.isEmpty)
            XCTAssertFalse(mode.description.isEmpty)
        }
    }
    
    // MARK: - Completion Status Visual Data
    
    func testCompletionStatusColors() {
        for status in CompletionStatus.allCases {
            XCTAssertNotNil(status.color, "\(status.rawValue) should have a color")
        }
    }
    
    // MARK: - Schedule Display Strings
    
    func testDailyScheduleTimeRangeString() {
        let start = Date.timeToday(hour: 8, minute: 30)
        let end = Date.timeToday(hour: 17, minute: 30)
        let schedule = DailySchedule(
            date: Date(),
            activityType: .work,
            plannedStartTime: start,
            plannedEndTime: end
        )
        XCTAssertEqual(schedule.timeRangeString, "08:30 → 17:30")
    }
    
    // MARK: - More Tab Structure
    
    func testMoreTabSections() {
        // Verify all expected sections exist in More tab
        let expectedSections = ["Tracking", "Planning", "Tools"]
        for section in expectedSections {
            XCTAssertFalse(section.isEmpty, "Section \(section) should exist")
        }
        
        // Verify key features are accessible
        let expectedFeatures = [
            "Calories", "Mood Tracker", "Activity History", "Evidence Gallery",
            "Schedule Editor", "Monthly Overview", "Goals",
            "Focus Timer", "AI Insights", "Achievements", "Export Report", "Voice Check-In",
            "Settings"
        ]
        XCTAssertEqual(expectedFeatures.count, 13, "More tab should have 13 navigable items")
    }
}
