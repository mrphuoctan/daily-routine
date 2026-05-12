import XCTest
import SwiftData
@testable import DailyRoutine

// MARK: - 3. WORKFLOW TESTS
/// Tests complete user workflows: check-in flow, daily routine, calorie tracking, settings
@MainActor
final class WorkflowTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        let schema = Schema([
            ActivityCategory.self, ScheduleTemplate.self, DailySchedule.self,
            ActivityLog.self, CheckInRecord.self, EvidencePhoto.self,
            ReminderItem.self, CalorieEntry.self, StatisticsCache.self
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
    
    // MARK: - Workflow 1: Complete Check-In/Out Flow
    
    func testFullCheckInCheckOutWorkflow() {
        // 1. User opens app -> seed data
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        // 2. Dashboard loads today's schedule
        let vm = DashboardViewModel()
        vm.loadData(modelContext: modelContext)
        XCTAssertGreaterThan(vm.todaySchedules.count, 0, "Dashboard should show activities")
        
        // 3. Find a schedule and check in
        guard let schedule = vm.todaySchedules.first else {
            XCTFail("No schedule available")
            return
        }
        let log = schedule.activityLog!
        
        // 4. Check In
        vm.checkIn(schedule: schedule)
        XCTAssertEqual(schedule.completionStatus, .inProgress)
        XCTAssertNotNil(log.actualStartTime)
        XCTAssertTrue(log.isActive)
        
        // 5. Timer should start
        let timer = TimerService.shared
        timer.start(activity: schedule.activity)
        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.activeActivityType, schedule.activity)
        
        // 6. Pause
        timer.pause()
        XCTAssertTrue(timer.isPaused)
        
        // 7. Resume
        timer.resume()
        XCTAssertFalse(timer.isPaused)
        
        // 8. Check Out
        vm.checkOut(schedule: schedule)
        let elapsed = timer.stop()
        XCTAssertEqual(schedule.completionStatus, .completed)
        XCTAssertNotNil(log.actualEndTime)
        XCTAssertFalse(log.isActive)
        XCTAssertGreaterThanOrEqual(elapsed, 0)
        
        // 9. Completion percentage should update
        vm.loadData(modelContext: modelContext)
        XCTAssertGreaterThan(vm.completedCount, 0)
    }
    
    // MARK: - Workflow 2: Skip Activity
    
    func testSkipActivityWorkflow() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let vm = DashboardViewModel()
        vm.loadData(modelContext: modelContext)
        
        guard let schedule = vm.todaySchedules.first else {
            XCTFail("No schedule")
            return
        }
        
        XCTAssertEqual(schedule.completionStatus, .pending)
        
        vm.skipActivity(schedule: schedule)
        XCTAssertEqual(schedule.completionStatus, .skipped)
    }
    
    // MARK: - Workflow 3: Daily Calorie Tracking
    
    func testFullCalorieTrackingWorkflow() {
        let vm = CalorieViewModel()
        
        // 1. Morning - add breakfast
        vm.addEntry(name: "Pho", calories: 450, isConsumed: true, note: "Breakfast", modelContext: modelContext)
        vm.loadEntries(modelContext: modelContext)
        XCTAssertEqual(vm.entries.count, 1)
        XCTAssertEqual(vm.dailyConsumed, 450)
        
        // 2. Lunch
        vm.addEntry(name: "Com ga", calories: 650, isConsumed: true, note: "Lunch", modelContext: modelContext)
        vm.loadEntries(modelContext: modelContext)
        XCTAssertEqual(vm.dailyConsumed, 1100)
        
        // 3. Gym workout
        vm.addEntry(name: "Gym session", calories: 400, isConsumed: false, note: "Evening workout", modelContext: modelContext)
        vm.loadEntries(modelContext: modelContext)
        XCTAssertEqual(vm.dailyBurned, 400)
        XCTAssertEqual(vm.dailyNet, 700) // 1100 - 400
        
        // 4. Dinner
        vm.addEntry(name: "Dinner", calories: 550, isConsumed: true, note: "", modelContext: modelContext)
        vm.loadEntries(modelContext: modelContext)
        XCTAssertEqual(vm.dailyConsumed, 1650)
        XCTAssertEqual(vm.dailyNet, 1250) // 1650 - 400
        
        // 5. Delete an entry
        let firstEntry = vm.entries.last! // oldest entry (Pho)
        vm.deleteEntry(firstEntry, modelContext: modelContext)
        XCTAssertEqual(vm.entries.count, 3)
    }
    
    // MARK: - Workflow 4: Schedule Generation
    
    func testScheduleGenerationWorkflow() {
        // 1. Seed templates
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        // 2. Templates should exist for all days
        let templates = try! modelContext.fetch(FetchDescriptor<ScheduleTemplate>())
        let daySet = Set(templates.map { $0.dayOfWeek })
        XCTAssertEqual(daySet.count, 7)
        
        // 3. Today's schedule should be auto-generated
        let todaySchedules = ScheduleService.getTodaySchedule(modelContext: modelContext)
        XCTAssertGreaterThan(todaySchedules.count, 0)
        
        // 4. Each schedule should have an associated log
        for schedule in todaySchedules {
            XCTAssertNotNil(schedule.activityLog, "Each schedule should have an activity log")
        }
        
        // 5. All should start as pending
        for schedule in todaySchedules {
            XCTAssertEqual(schedule.completionStatus, .pending)
        }
    }
    
    // MARK: - Workflow 5: Language Switching
    
    func testLanguageSwitchingWorkflow() {
        let service = LocalizationService.shared
        
        // Start with English
        service.currentLanguage = .english
        XCTAssertEqual(service.locale.identifier, "en")
        
        // Switch to Vietnamese
        service.currentLanguage = .vietnamese
        XCTAssertEqual(service.locale.identifier, "vi")
        
        // Switch to Chinese
        service.currentLanguage = .chinese
        XCTAssertEqual(service.locale.identifier, "zh-Hans")
        
        // Persistence check
        let savedLang = UserDefaults.standard.string(forKey: "app_language")
        XCTAssertEqual(savedLang, "zh-Hans")
        
        // Reset
        service.currentLanguage = .english
    }
    
    // MARK: - Workflow 6: Settings Reset
    
    func testSettingsResetWorkflow() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        // Verify data exists
        XCTAssertGreaterThan(try! modelContext.fetchCount(FetchDescriptor<ScheduleTemplate>()), 0)
        XCTAssertGreaterThan(try! modelContext.fetchCount(FetchDescriptor<ActivityCategory>()), 0)
        
        // Reset
        let vm = SettingsViewModel()
        vm.resetAllData(modelContext: modelContext)
        
        // Data should be re-seeded (not empty)
        XCTAssertGreaterThan(try! modelContext.fetchCount(FetchDescriptor<ScheduleTemplate>()), 0)
        XCTAssertGreaterThan(try! modelContext.fetchCount(FetchDescriptor<ActivityCategory>()), 0)
    }
    
    // MARK: - Workflow 7: Timeline Navigation
    
    func testTimelineNavigationWorkflow() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let vm = TimelineViewModel()
        
        // Load today
        vm.loadSchedules(for: Date(), modelContext: modelContext)
        XCTAssertGreaterThan(vm.schedules.count, 0)
        
        // Navigate to tomorrow
        let tomorrow = Date().adding(days: 1)
        vm.loadSchedules(for: tomorrow, modelContext: modelContext)
        XCTAssertTrue(vm.selectedDate.isSameDay(as: tomorrow))
    }
    
    // MARK: - Workflow 8: Weekly Calendar
    
    func testWeeklyCalendarWorkflow() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let vm = WeeklyCalendarViewModel()
        XCTAssertEqual(vm.weekDates.count, 7)
        
        // Load week data
        vm.loadWeekData(modelContext: modelContext)
        
        // Navigate forward
        let firstDateBefore = vm.weekDates.first!
        vm.navigateWeek(forward: true)
        XCTAssertGreaterThan(vm.weekDates.first!, firstDateBefore)
        
        // Navigate back
        vm.navigateWeek(forward: false)
        XCTAssertTrue(vm.weekDates.first!.isSameDay(as: firstDateBefore))
    }
}
