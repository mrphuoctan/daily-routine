import XCTest
import SwiftData
@testable import DailyRoutine

// MARK: - 2. BACKEND / SERVICE TESTS
/// Tests business logic in Services and ViewModels
@MainActor
final class BackendTests: XCTestCase {
    
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
    
    // MARK: - ScheduleService Tests
    
    func testGenerateDailyScheduleFromTemplates() {
        // Seed templates first
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let templates = try! modelContext.fetch(FetchDescriptor<ScheduleTemplate>())
        let todaySchedules = ScheduleService.getTodaySchedule(modelContext: modelContext)
        
        XCTAssertGreaterThan(todaySchedules.count, 0, "Should generate today's schedule")
    }
    
    func testScheduleServiceHasSchedule() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let hasSchedule = ScheduleService.hasSchedule(for: Date(), modelContext: modelContext)
        XCTAssertTrue(hasSchedule, "Today should have a schedule after seeding")
    }
    
    func testCompletionPercentageEmpty() {
        let percentage = ScheduleService.completionPercentage(for: [])
        XCTAssertEqual(percentage, 0)
    }
    
    func testCompletionPercentageCalculation() {
        let s1 = DailySchedule(date: Date(), activityType: .work, plannedStartTime: Date(), plannedEndTime: Date().adding(hours: 1))
        s1.completionStatus = .completed
        
        let s2 = DailySchedule(date: Date(), activityType: .gym, plannedStartTime: Date(), plannedEndTime: Date().adding(hours: 1))
        s2.completionStatus = .pending
        
        let percentage = ScheduleService.completionPercentage(for: [s1, s2])
        XCTAssertEqual(percentage, 0.5, accuracy: 0.01)
    }
    
    func testCurrentActivityDetection() {
        let now = Date()
        let past = DailySchedule(date: now, activityType: .work, plannedStartTime: now.adding(hours: -3), plannedEndTime: now.adding(hours: -1))
        let current = DailySchedule(date: now, activityType: .freelancer, plannedStartTime: now.adding(hours: -1), plannedEndTime: now.adding(hours: 1))
        let future = DailySchedule(date: now, activityType: .hsk, plannedStartTime: now.adding(hours: 2), plannedEndTime: now.adding(hours: 3))
        
        let found = ScheduleService.getCurrentActivity(from: [past, current, future])
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.activity, .freelancer)
    }
    
    func testNextActivityDetection() {
        let now = Date()
        let current = DailySchedule(date: now, activityType: .freelancer, plannedStartTime: now.adding(hours: -1), plannedEndTime: now.adding(hours: 1))
        let next = DailySchedule(date: now, activityType: .hsk, plannedStartTime: now.adding(hours: 2), plannedEndTime: now.adding(hours: 3))
        
        let found = ScheduleService.getNextActivity(from: [current, next])
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.activity, .hsk)
    }
    
    // MARK: - TimerService Tests
    
    func testTimerServiceStartStop() {
        let timer = TimerService.shared
        
        XCTAssertFalse(timer.isRunning)
        XCTAssertNil(timer.activeActivityType)
        
        timer.start(activity: .work)
        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.activeActivityType, .work)
        XCTAssertFalse(timer.isPaused)
        
        let elapsed = timer.stop()
        XCTAssertFalse(timer.isRunning)
        XCTAssertNil(timer.activeActivityType)
        XCTAssertGreaterThanOrEqual(elapsed, 0)
    }
    
    func testTimerServicePauseResume() {
        let timer = TimerService.shared
        
        timer.start(activity: .freelancer)
        XCTAssertFalse(timer.isPaused)
        
        timer.pause()
        XCTAssertTrue(timer.isPaused)
        XCTAssertTrue(timer.isRunning) // Still running, just paused
        
        timer.resume()
        XCTAssertFalse(timer.isPaused)
        XCTAssertTrue(timer.isRunning)
        
        _ = timer.stop()
    }
    
    // MARK: - LocalizationService Tests
    
    func testLocalizationLanguageSwitching() {
        let service = LocalizationService.shared
        
        service.currentLanguage = .english
        XCTAssertEqual(service.currentLanguage, .english)
        XCTAssertEqual(service.currentLanguage.displayName, "English")
        
        service.currentLanguage = .vietnamese
        XCTAssertEqual(service.currentLanguage, .vietnamese)
        XCTAssertEqual(service.currentLanguage.displayName, "Tiếng Việt")
        
        service.currentLanguage = .chinese
        XCTAssertEqual(service.currentLanguage, .chinese)
        XCTAssertEqual(service.currentLanguage.displayName, "简体中文")
        
        // Reset to English
        service.currentLanguage = .english
    }
    
    func testLocalizationFlags() {
        XCTAssertEqual(LocalizationService.Language.english.flag, "🇺🇸")
        XCTAssertEqual(LocalizationService.Language.vietnamese.flag, "🇻🇳")
        XCTAssertEqual(LocalizationService.Language.chinese.flag, "🇨🇳")
    }
    
    func testAllLanguagesHaveLocale() {
        for lang in LocalizationService.Language.allCases {
            XCTAssertFalse(lang.locale.identifier.isEmpty)
        }
    }
    
    // MARK: - DashboardViewModel Tests
    
    func testDashboardViewModelLoadData() {
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        
        let vm = DashboardViewModel()
        vm.loadData(modelContext: modelContext)
        
        XCTAssertGreaterThan(vm.todaySchedules.count, 0)
        XCTAssertEqual(vm.totalCount, vm.todaySchedules.count)
    }
    
    func testDashboardCheckIn() {
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
        
        let vm = DashboardViewModel()
        vm.checkIn(schedule: schedule)
        
        XCTAssertEqual(schedule.completionStatus, .inProgress)
        XCTAssertNotNil(log.actualStartTime)
    }
    
    func testDashboardCheckOut() {
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
        log.checkIn()
        
        let vm = DashboardViewModel()
        vm.checkOut(schedule: schedule)
        
        XCTAssertEqual(schedule.completionStatus, .completed)
        XCTAssertNotNil(log.actualEndTime)
    }
    
    func testDashboardSkipActivity() {
        let schedule = DailySchedule(
            date: Date(),
            activityType: .gym,
            plannedStartTime: Date(),
            plannedEndTime: Date().adding(hours: 1)
        )
        let log = ActivityLog(
            activityType: .gym,
            date: Date(),
            plannedStartTime: Date(),
            plannedEndTime: Date().adding(hours: 1)
        )
        schedule.activityLog = log
        
        let vm = DashboardViewModel()
        vm.skipActivity(schedule: schedule)
        
        XCTAssertEqual(schedule.completionStatus, .skipped)
    }
    
    // MARK: - CalorieViewModel Tests
    
    func testCalorieViewModelAddEntry() {
        let vm = CalorieViewModel()
        vm.addEntry(name: "Pho", calories: 450, isConsumed: true, note: "Breakfast", modelContext: modelContext)
        
        let entries = try! modelContext.fetch(FetchDescriptor<CalorieEntry>())
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.name, "Pho")
        XCTAssertEqual(entries.first?.calories, 450)
    }
    
    func testCalorieViewModelDeleteEntry() {
        let entry = CalorieEntry(name: "Test", calories: 100)
        modelContext.insert(entry)
        try! modelContext.save()
        
        let vm = CalorieViewModel()
        vm.deleteEntry(entry, modelContext: modelContext)
        
        let entries = try! modelContext.fetch(FetchDescriptor<CalorieEntry>())
        XCTAssertEqual(entries.count, 0)
    }
    
    func testCalorieViewModelDailySummary() {
        // Add consumed
        let food = CalorieEntry(name: "Rice", calories: 500, isConsumed: true)
        modelContext.insert(food)
        
        // Add burned
        let exercise = CalorieEntry(name: "Run", calories: 200, isConsumed: false)
        modelContext.insert(exercise)
        try! modelContext.save()
        
        let vm = CalorieViewModel()
        vm.loadEntries(modelContext: modelContext)
        
        XCTAssertEqual(vm.dailyConsumed, 500)
        XCTAssertEqual(vm.dailyBurned, 200)
        XCTAssertEqual(vm.dailyNet, 300)
    }
}
