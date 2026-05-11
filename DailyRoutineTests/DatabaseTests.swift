import XCTest
import SwiftData
@testable import DailyRoutine

// MARK: - 1. DATABASE TESTS
/// Tests SwiftData model creation, relationships, CRUD operations, and data integrity
final class DatabaseTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        let schema = Schema([
            ActivityCategory.self,
            ScheduleTemplate.self,
            DailySchedule.self,
            ActivityLog.self,
            CheckInRecord.self,
            EvidencePhoto.self,
            ReminderItem.self,
            CalorieEntry.self,
            StatisticsCache.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext
    }
    
    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        super.tearDown()
    }
    
    // MARK: - ActivityCategory Tests
    
    func testCreateActivityCategory() {
        let category = ActivityCategory(
            name: "Work",
            type: .work,
            colorHex: "007AFF",
            defaultDurationMinutes: 540
        )
        modelContext.insert(category)
        try! modelContext.save()
        
        let fetched = try! modelContext.fetch(FetchDescriptor<ActivityCategory>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Work")
        XCTAssertEqual(fetched.first?.categoryType, .work)
        XCTAssertEqual(fetched.first?.defaultDurationMinutes, 540)
    }
    
    func testCategoryTypes() {
        for catType in ActivityCategoryType.allCases {
            let category = ActivityCategory(name: catType.rawValue, type: catType)
            modelContext.insert(category)
        }
        try! modelContext.save()
        
        let fetched = try! modelContext.fetch(FetchDescriptor<ActivityCategory>())
        XCTAssertEqual(fetched.count, ActivityCategoryType.allCases.count)
    }
    
    // MARK: - ScheduleTemplate Tests
    
    func testCreateScheduleTemplate() {
        let template = ScheduleTemplate(
            activityType: .work,
            dayOfWeek: .monday,
            startHour: 8, startMinute: 30,
            endHour: 17, endMinute: 30
        )
        modelContext.insert(template)
        try! modelContext.save()
        
        let fetched = try! modelContext.fetch(FetchDescriptor<ScheduleTemplate>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.activity, .work)
        XCTAssertEqual(fetched.first?.day, .monday)
        XCTAssertEqual(fetched.first?.durationMinutes, 540) // 9 hours
    }
    
    func testTemplateDurationCalculation() {
        let template = ScheduleTemplate(
            activityType: .gym,
            dayOfWeek: .tuesday,
            startHour: 5, startMinute: 30,
            endHour: 6, endMinute: 40
        )
        XCTAssertEqual(template.durationMinutes, 70) // 1h10m
        XCTAssertEqual(template.startTimeString, "05:30")
        XCTAssertEqual(template.endTimeString, "06:40")
    }
    
    func testTemplateMidnightCrossing() {
        let template = ScheduleTemplate(
            activityType: .consoleRelax,
            dayOfWeek: .monday,
            startHour: 23, startMinute: 30,
            endHour: 0, endMinute: 0
        )
        XCTAssertEqual(template.durationMinutes, 30) // 30 minutes crossing midnight
    }
    
    // MARK: - DailySchedule Tests
    
    func testCreateDailySchedule() {
        let start = Date.timeToday(hour: 8, minute: 30)
        let end = Date.timeToday(hour: 17, minute: 30)
        
        let schedule = DailySchedule(
            date: Date(),
            activityType: .work,
            plannedStartTime: start,
            plannedEndTime: end
        )
        modelContext.insert(schedule)
        try! modelContext.save()
        
        let fetched = try! modelContext.fetch(FetchDescriptor<DailySchedule>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.activity, .work)
        XCTAssertEqual(fetched.first?.plannedDurationMinutes, 540)
        XCTAssertEqual(fetched.first?.completionStatus, .pending)
    }
    
    func testScheduleStatusTransitions() {
        let schedule = DailySchedule(
            date: Date(),
            activityType: .work,
            plannedStartTime: Date(),
            plannedEndTime: Date().adding(hours: 2)
        )
        
        XCTAssertEqual(schedule.completionStatus, .pending)
        
        schedule.completionStatus = .inProgress
        XCTAssertEqual(schedule.completionStatus, .inProgress)
        
        schedule.completionStatus = .completed
        XCTAssertEqual(schedule.completionStatus, .completed)
    }
    
    // MARK: - ActivityLog Tests
    
    func testActivityLogCheckInOut() {
        let log = ActivityLog(
            activityType: .freelancer,
            date: Date(),
            plannedStartTime: Date.timeToday(hour: 20, minute: 0),
            plannedEndTime: Date.timeToday(hour: 23, minute: 0)
        )
        modelContext.insert(log)
        
        // Check In
        log.checkIn()
        XCTAssertNotNil(log.actualStartTime)
        XCTAssertEqual(log.completionStatus, .inProgress)
        XCTAssertTrue(log.isActive)
        
        // Check Out
        log.checkOut()
        XCTAssertNotNil(log.actualEndTime)
        XCTAssertEqual(log.completionStatus, .completed)
        XCTAssertFalse(log.isActive)
        XCTAssertNotNil(log.actualDurationMinutes)
    }
    
    func testActivityLogDurationDifference() {
        let start = Date.timeToday(hour: 20, minute: 0)
        let end = Date.timeToday(hour: 23, minute: 0)
        
        let log = ActivityLog(
            activityType: .freelancer,
            date: Date(),
            plannedStartTime: start,
            plannedEndTime: end
        )
        
        XCTAssertEqual(log.plannedDurationMinutes, 180) // 3 hours
        XCTAssertNil(log.actualDurationMinutes)
        XCTAssertNil(log.durationDifferenceMinutes)
    }
    
    // MARK: - CheckInRecord Tests
    
    func testCheckInRecordCreation() {
        let checkIn = Date()
        let checkOut = checkIn.adding(minutes: 45)
        
        let record = CheckInRecord(checkInTime: checkIn, checkOutTime: checkOut)
        XCTAssertEqual(record.durationMinutes, 45)
        XCTAssertFalse(record.isActive)
    }
    
    func testActiveCheckInRecord() {
        let record = CheckInRecord(checkInTime: Date())
        XCTAssertTrue(record.isActive)
        XCTAssertNil(record.checkOutTime)
        
        record.complete()
        XCTAssertFalse(record.isActive)
        XCTAssertNotNil(record.checkOutTime)
    }
    
    // MARK: - CalorieEntry Tests
    
    func testCalorieEntryConsumed() {
        let entry = CalorieEntry(name: "Chicken rice", calories: 650, isConsumed: true)
        XCTAssertEqual(entry.calories, 650)
        XCTAssertEqual(entry.effectiveCalories, 650)
        XCTAssertEqual(entry.displayCalories, "+650 kcal")
        XCTAssertTrue(entry.isConsumed)
    }
    
    func testCalorieEntryBurned() {
        let entry = CalorieEntry(name: "Running", calories: 350, isConsumed: false)
        XCTAssertEqual(entry.calories, 350)
        XCTAssertEqual(entry.effectiveCalories, -350)
        XCTAssertEqual(entry.displayCalories, "-350 kcal")
        XCTAssertFalse(entry.isConsumed)
    }
    
    func testCalorieEntryNegativeInputNormalized() {
        let entry = CalorieEntry(name: "Running", calories: -350, isConsumed: false)
        XCTAssertEqual(entry.calories, 350) // abs() applied
    }
    
    // MARK: - ReminderItem Tests
    
    func testReminderCreation() {
        let reminder = ReminderItem(
            title: "Time for HSK",
            body: "Start Chinese study",
            activityType: .hsk,
            hour: 19, minute: 0,
            isWeekdayOnly: false,
            isWeekendOnly: false
        )
        
        XCTAssertEqual(reminder.title, "Time for HSK")
        XCTAssertEqual(reminder.activity, .hsk)
        XCTAssertEqual(reminder.timeString, "19:00")
        XCTAssertTrue(reminder.isEnabled)
    }
    
    // MARK: - EvidencePhoto Tests
    
    func testEvidencePhotoCreation() {
        let photo = EvidencePhoto(caption: "Gym selfie")
        XCTAssertNil(photo.imageData)
        XCTAssertEqual(photo.caption, "Gym selfie")
    }
    
    // MARK: - StatisticsCache Tests
    
    func testStatisticsCacheCreation() {
        let cache = StatisticsCache(
            date: Date(),
            period: "weekly",
            totalPlannedMinutes: 2700,
            totalActualMinutes: 2500,
            completionRate: 0.85,
            streakDays: 7,
            focusScore: 92.5
        )
        
        XCTAssertEqual(cache.period, "weekly")
        XCTAssertEqual(cache.completionRate, 0.85)
        XCTAssertEqual(cache.streakDays, 7)
    }
    
    // MARK: - Data Seeder Tests
    
    func testDataSeederPopulatesTemplates() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let templates = try! modelContext.fetch(FetchDescriptor<ScheduleTemplate>())
        XCTAssertGreaterThan(templates.count, 0, "Seeder should create schedule templates")
        
        // Verify all 7 days have templates
        let days = Set(templates.map { $0.dayOfWeek })
        XCTAssertEqual(days.count, 7, "Should have templates for all 7 days")
    }
    
    func testDataSeederPopulatesCategories() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let categories = try! modelContext.fetch(FetchDescriptor<ActivityCategory>())
        XCTAssertEqual(categories.count, 6, "Should create 6 default categories")
    }
    
    func testDataSeederPopulatesReminders() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let reminders = try! modelContext.fetch(FetchDescriptor<ReminderItem>())
        XCTAssertGreaterThan(reminders.count, 0, "Should create default reminders")
    }
    
    func testDataSeederIdempotent() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        let count1 = try! modelContext.fetchCount(FetchDescriptor<ScheduleTemplate>())
        
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        let count2 = try! modelContext.fetchCount(FetchDescriptor<ScheduleTemplate>())
        
        XCTAssertEqual(count1, count2, "Seeder should not duplicate data on second run")
    }
    
    // MARK: - Relationship Tests
    
    func testScheduleLogRelationship() {
        let schedule = DailySchedule(
            date: Date(),
            activityType: .work,
            plannedStartTime: Date(),
            plannedEndTime: Date().adding(hours: 2)
        )
        
        let log = ActivityLog(
            activityType: .work,
            date: Date(),
            plannedStartTime: Date(),
            plannedEndTime: Date().adding(hours: 2)
        )
        
        schedule.activityLog = log
        modelContext.insert(schedule)
        try! modelContext.save()
        
        let fetched = try! modelContext.fetch(FetchDescriptor<DailySchedule>())
        XCTAssertNotNil(fetched.first?.activityLog)
    }
    
    // MARK: - CRUD Tests
    
    func testDeleteCalorieEntry() {
        let entry = CalorieEntry(name: "Test", calories: 100)
        modelContext.insert(entry)
        try! modelContext.save()
        
        XCTAssertEqual(try! modelContext.fetchCount(FetchDescriptor<CalorieEntry>()), 1)
        
        modelContext.delete(entry)
        try! modelContext.save()
        
        XCTAssertEqual(try! modelContext.fetchCount(FetchDescriptor<CalorieEntry>()), 0)
    }
    
    func testUpdateScheduleStatus() {
        let schedule = DailySchedule(
            date: Date(),
            activityType: .gym,
            plannedStartTime: Date(),
            plannedEndTime: Date().adding(hours: 1)
        )
        modelContext.insert(schedule)
        try! modelContext.save()
        
        schedule.completionStatus = .completed
        try! modelContext.save()
        
        let fetched = try! modelContext.fetch(FetchDescriptor<DailySchedule>())
        XCTAssertEqual(fetched.first?.completionStatus, .completed)
    }
}
