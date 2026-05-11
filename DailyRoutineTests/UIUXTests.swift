import XCTest
@testable import DailyRoutine

// MARK: - 4. UI/UX VALIDATION TESTS
/// Tests UI component data, theme consistency, accessibility, and visual correctness
final class UIUXTests: XCTestCase {
    
    // MARK: - Activity Type Consistency
    
    func testAllActivityTypesHaveColors() {
        for type in ActivityType.allCases {
            let color = type.color
            XCTAssertNotNil(color, "\(type.rawValue) should have a color")
        }
    }
    
    func testAllActivityTypesHaveIcons() {
        for type in ActivityType.allCases {
            let icon = type.icon
            XCTAssertFalse(icon.isEmpty, "\(type.rawValue) should have an icon")
        }
    }
    
    func testAllActivityTypesHaveCategories() {
        for type in ActivityType.allCases {
            let category = type.category
            XCTAssertNotNil(category, "\(type.rawValue) should map to a category")
        }
    }
    
    func testAllActivityTypesHaveLocalizedKeys() {
        for type in ActivityType.allCases {
            let key = type.localizedKey
            XCTAssertFalse(key.isEmpty, "\(type.rawValue) should have a localized key")
        }
    }
    
    // MARK: - Category Consistency
    
    func testAllCategoryTypesHaveColors() {
        for cat in ActivityCategoryType.allCases {
            let color = cat.color
            XCTAssertNotNil(color, "\(cat.rawValue) should have a color")
        }
    }
    
    func testAllCategoryTypesHaveIcons() {
        for cat in ActivityCategoryType.allCases {
            let icon = cat.icon
            XCTAssertFalse(icon.isEmpty, "\(cat.rawValue) should have an icon")
        }
    }
    
    // MARK: - Completion Status Consistency
    
    func testAllCompletionStatusesHaveColors() {
        for status in CompletionStatus.allCases {
            let color = status.color
            XCTAssertNotNil(color, "\(status.rawValue) should have a color")
        }
    }
    
    // MARK: - Day of Week
    
    func testDayOfWeekShortNames() {
        for day in DayOfWeek.allCases {
            XCTAssertFalse(day.shortName.isEmpty)
            XCTAssertTrue(day.shortName.count <= 3, "Short name should be 3 chars max")
        }
    }
    
    func testWeekdayDetection() {
        XCTAssertTrue(DayOfWeek.monday.isWeekday)
        XCTAssertTrue(DayOfWeek.friday.isWeekday)
        XCTAssertFalse(DayOfWeek.saturday.isWeekday)
        XCTAssertFalse(DayOfWeek.sunday.isWeekday)
    }
    
    // MARK: - Date Extensions
    
    func testDateFormatDuration() {
        XCTAssertEqual(Date.formatDuration(minutes: 0), "0m")
        XCTAssertEqual(Date.formatDuration(minutes: 30), "30m")
        XCTAssertEqual(Date.formatDuration(minutes: 60), "1h")
        XCTAssertEqual(Date.formatDuration(minutes: 90), "1h 30m")
        XCTAssertEqual(Date.formatDuration(minutes: 540), "9h")
    }
    
    func testDateTimerFormat() {
        XCTAssertEqual(Date.formatTimerDuration(seconds: 0), "00:00")
        XCTAssertEqual(Date.formatTimerDuration(seconds: 65), "01:05")
        XCTAssertEqual(Date.formatTimerDuration(seconds: 3661), "01:01:01")
    }
    
    func testDateTimeToday() {
        let date = Date.timeToday(hour: 14, minute: 30)
        XCTAssertEqual(date.hour, 14)
        XCTAssertEqual(date.minute, 30)
    }
    
    func testDateIsSameDay() {
        let now = Date()
        let laterToday = now.adding(hours: 1)
        let tomorrow = now.adding(days: 1)
        
        XCTAssertTrue(now.isSameDay(as: laterToday))
        XCTAssertFalse(now.isSameDay(as: tomorrow))
    }
    
    func testDateAdding() {
        let base = Date.timeToday(hour: 10, minute: 0)
        
        let plus2h = base.adding(hours: 2)
        XCTAssertEqual(plus2h.hour, 12)
        
        let plus30m = base.adding(minutes: 30)
        XCTAssertEqual(plus30m.minute, 30)
    }
    
    // MARK: - Theme Colors
    
    func testThemeColorsExist() {
        let theme = Color.theme
        XCTAssertNotNil(theme.primary)
        XCTAssertNotNil(theme.primaryLight)
        XCTAssertNotNil(theme.accent)
        XCTAssertNotNil(theme.accentLight)
        XCTAssertNotNil(theme.success)
        XCTAssertNotNil(theme.warning)
        XCTAssertNotNil(theme.error)
        XCTAssertNotNil(theme.textSecondary)
    }
    
    func testThemeGradientsExist() {
        let theme = Color.theme
        XCTAssertNotNil(theme.primaryGradient)
        XCTAssertNotNil(theme.accentGradient)
        XCTAssertNotNil(theme.surfaceGradient)
    }
    
    // MARK: - Color Hex Initialization
    
    func testColorHexInit() {
        let color = Color(hex: "007AFF")
        XCTAssertNotNil(color)
        
        let color2 = Color(hex: "#FF0000")
        XCTAssertNotNil(color2)
        
        let color3 = Color(hex: "FFF")
        XCTAssertNotNil(color3)
    }
    
    // MARK: - Activity Count Validation (from spec)
    
    func testActivityTypeCount() {
        // The spec defines 19 activity types
        XCTAssertEqual(ActivityType.allCases.count, 19, "Should have 19 activity types as per spec")
    }
    
    func testCategoryTypeCount() {
        // 6 categories: Work, Study, Fitness, Relationship, Relax, Commute
        XCTAssertEqual(ActivityCategoryType.allCases.count, 6)
    }
    
    // MARK: - AppConstants Validation
    
    func testAppConstants() {
        XCTAssertEqual(AppConstants.appName, "Daily Routine")
        XCTAssertEqual(AppConstants.appVersion, "1.0.0")
        XCTAssertGreaterThan(AppConstants.cornerRadius, 0)
        XCTAssertGreaterThan(AppConstants.cardPadding, 0)
        XCTAssertGreaterThan(AppConstants.screenPadding, 0)
    }
    
    // MARK: - Schedule Template Display
    
    func testScheduleTemplateTimeStrings() {
        let template = ScheduleTemplate(
            activityType: .work,
            dayOfWeek: .monday,
            startHour: 8, startMinute: 30,
            endHour: 17, endMinute: 30
        )
        XCTAssertEqual(template.startTimeString, "08:30")
        XCTAssertEqual(template.endTimeString, "17:30")
    }
    
    // MARK: - DailySchedule Display
    
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
    
    // MARK: - Calorie Display
    
    func testCalorieDisplayStrings() {
        let food = CalorieEntry(name: "Rice", calories: 500, isConsumed: true)
        XCTAssertEqual(food.displayCalories, "+500 kcal")
        
        let exercise = CalorieEntry(name: "Run", calories: 300, isConsumed: false)
        XCTAssertEqual(exercise.displayCalories, "-300 kcal")
    }
    
    // MARK: - Reminder Display
    
    func testReminderTimeString() {
        let reminder = ReminderItem(
            title: "Test", activityType: .hsk,
            hour: 7, minute: 5
        )
        XCTAssertEqual(reminder.timeString, "07:05")
    }
}

// Make CompletionStatus conform to CaseIterable for testing
extension CompletionStatus: CaseIterable {
    public static var allCases: [CompletionStatus] = [.pending, .inProgress, .completed, .skipped, .overdue]
}
