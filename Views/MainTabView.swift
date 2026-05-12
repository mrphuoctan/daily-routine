import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
            
            // Floating Mini Player above tab bar
            VStack {
                Spacer()
                MiniPlayerView()
                    .padding(.bottom, 50) // above tab bar
            }
        }
    }
}

// MARK: - More View (hub for Calories, History, Settings)
struct MoreView: View {
    @EnvironmentObject var localizationService: LocalizationService
    @State private var showVoiceCheckIn = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Tracking
                Section("Tracking") {
                    NavigationLink {
                        CalorieView()
                    } label: {
                        Label(localizationService.localized("tab_calories"), systemImage: "flame.fill")
                            .foregroundStyle(Color.theme.accent)
                    }
                    
                    NavigationLink {
                        MoodTrackingView()
                    } label: {
                        Label("Mood Tracker", systemImage: "face.smiling")
                            .foregroundStyle(Color(hex: "FF6482"))
                    }
                    
                    NavigationLink {
                        ActivityHistoryView()
                    } label: {
                        Label(localizationService.localized("tab_history"), systemImage: "clock.arrow.circlepath")
                            .foregroundStyle(Color.theme.primary)
                    }
                    
                    NavigationLink {
                        EvidenceGalleryView()
                    } label: {
                        Label("Evidence Gallery", systemImage: "photo.on.rectangle.angled")
                            .foregroundStyle(Color(hex: "FF6B35"))
                    }
                }
                
                // MARK: - Planning
                Section("Planning") {
                    NavigationLink {
                        ScheduleEditorView()
                    } label: {
                        Label(localizationService.localized("tab_schedule_editor"), systemImage: "pencil.and.list.clipboard")
                            .foregroundStyle(Color.theme.success)
                    }
                    
                    NavigationLink {
                        MonthlyOverviewView()
                    } label: {
                        Label("Monthly Overview", systemImage: "calendar.badge.clock")
                            .foregroundStyle(Color(hex: "AF52DE"))
                    }
                    
                    NavigationLink {
                        GoalView()
                    } label: {
                        Label("Goals", systemImage: "target")
                            .foregroundStyle(Color(hex: "FF9500"))
                    }
                }
                
                // MARK: - Tools
                Section("Tools") {
                    NavigationLink {
                        FocusTimerView()
                    } label: {
                        Label("Focus Timer", systemImage: "timer")
                            .foregroundStyle(Color(hex: "007AFF"))
                    }
                    
                    NavigationLink {
                        AIInsightsView()
                    } label: {
                        Label("AI Insights", systemImage: "brain.head.profile")
                            .foregroundStyle(Color(hex: "FF2D55"))
                    }
                    
                    NavigationLink {
                        AchievementView()
                    } label: {
                        Label("Achievements", systemImage: "trophy.fill")
                            .foregroundStyle(Color(hex: "FFD700"))
                    }
                    
                    NavigationLink {
                        ExportReportView()
                    } label: {
                        Label("Export Report", systemImage: "square.and.arrow.up")
                            .foregroundStyle(Color(hex: "30B0C7"))
                    }
                    
                    Button {
                        showVoiceCheckIn = true
                    } label: {
                        Label("Voice Check-In", systemImage: "mic.fill")
                            .foregroundStyle(Color(hex: "5856D6"))
                    }
                }
                
                // MARK: - Settings
                Section {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label(localizationService.localized("tab_settings"), systemImage: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(localizationService.localized("tab_more"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showVoiceCheckIn) {
                VoiceCheckInView { activity in
                    print("Voice check-in: \(activity.rawValue)")
                }
            }
        }
    }
}
