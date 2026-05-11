import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(localizationService.localized("tab_dashboard"))
                }
                .tag(0)
            
            DailyTimelineView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text(localizationService.localized("tab_timeline"))
                }
                .tag(1)
            
            WeeklyCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text(localizationService.localized("tab_weekly"))
                }
                .tag(2)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text(localizationService.localized("tab_analytics"))
                }
                .tag(3)
            
            CalorieView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text(localizationService.localized("tab_calories"))
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(localizationService.localized("tab_settings"))
                }
                .tag(5)
        }
        .tint(Color.theme.primary)
    }
}
