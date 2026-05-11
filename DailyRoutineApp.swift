import SwiftUI
import SwiftData

@main
struct DailyRoutineApp: App {
    @StateObject private var localizationService = LocalizationService.shared
    @StateObject private var timerService = TimerService.shared
    
    var sharedModelContainer: ModelContainer = {
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
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(localizationService)
                .environmentObject(timerService)
                .onAppear {
                    DataSeeder.seedIfNeeded(modelContext: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
