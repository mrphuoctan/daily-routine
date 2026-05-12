import SwiftUI
import SwiftData

@main
struct DailyRoutineApp: App {
    @StateObject private var localizationService = LocalizationService.shared
    @StateObject private var timerService = TimerService.shared
    @AppStorage("app_color_scheme") private var colorSchemeRaw: String = "system"
    
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
            StatisticsCache.self,
            Goal.self,
            Achievement.self,
            MoodEntry.self
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
    
    private var preferredScheme: ColorScheme? {
        switch colorSchemeRaw {
        case "dark": return .dark
        case "light": return .light
        default: return nil // system
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(localizationService)
                .environmentObject(timerService)
                .preferredColorScheme(preferredScheme)
                .onAppear {
                    DataSeeder.seedIfNeeded(modelContext: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
