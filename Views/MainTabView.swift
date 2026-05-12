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
            
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text(localizationService.localized("tab_more"))
                }
                .tag(4)
        }
        .tint(Color.theme.primary)
    }
}

// MARK: - More View (hub for Calories, History, Settings)
struct MoreView: View {
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    CalorieView()
                } label: {
                    Label(localizationService.localized("tab_calories"), systemImage: "flame.fill")
                        .foregroundStyle(Color.theme.accent)
                }
                
                NavigationLink {
                    ActivityHistoryView()
                } label: {
                    Label(localizationService.localized("tab_history"), systemImage: "clock.arrow.circlepath")
                        .foregroundStyle(Color.theme.primary)
                }
                
                NavigationLink {
                    ScheduleEditorView()
                } label: {
                    Label(localizationService.localized("tab_schedule_editor"), systemImage: "pencil.and.list.clipboard")
                        .foregroundStyle(Color.theme.success)
                }
                
                NavigationLink {
                    SettingsView()
                } label: {
                    Label(localizationService.localized("tab_settings"), systemImage: "gearshape.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(localizationService.localized("tab_more"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
