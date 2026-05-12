import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @EnvironmentObject var timerService: TimerService
    @State private var viewModel = DashboardViewModel()
    @State private var showingActivityDetail = false
    @State private var selectedSchedule: DailySchedule?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Current Activity Card
                    if let current = viewModel.currentActivity {
                        CurrentActivityCard(
                            schedule: current,
                            onCheckIn: { viewModel.checkIn(schedule: current); timerService.start(activity: current.activity) },
                            onCheckOut: { viewModel.checkOut(schedule: current); _ = timerService.stop() }
                        )
                        .transition(.asymmetric(insertion: .slide, removal: .opacity))
                    }
                    
                    // Progress Ring
                    ProgressRingView(
                        progress: viewModel.completionPercentage,
                        completed: viewModel.completedCount,
                        total: viewModel.totalCount,
                        freeMinutes: viewModel.remainingFreeMinutes
                    )
                    
                    // Quick Actions
                    if let current = viewModel.currentActivity {
                        QuickActionsView(
                            schedule: current,
                            onCheckIn: { viewModel.checkIn(schedule: current); timerService.start(activity: current.activity) },
                            onCheckOut: { viewModel.checkOut(schedule: current); _ = timerService.stop() },
                            onSkip: { viewModel.skipActivity(schedule: current) },
                            onPause: { timerService.pause() },
                            onResume: { timerService.resume() }
                        )
                    }
                    
                    // Upcoming Activity
                    if let next = viewModel.nextActivity {
                        UpcomingActivityCard(schedule: next)
                    }
                    
                    // Today's Schedule Preview
                    todayPreviewSection
                }
                .padding(.horizontal, AppConstants.screenPadding)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(localizationService.localized("dashboard_title"))
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                viewModel.loadData(modelContext: modelContext)
            }
        }
        .onAppear {
            viewModel.loadData(modelContext: modelContext)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Date().dayOfWeekString(locale: localizationService.locale))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Text(Date().dateString(locale: localizationService.locale))
                .font(.title2)
                .fontWeight(.bold)
            
            if timerService.isRunning, let activity = timerService.activeActivityType {
                HStack(spacing: 8) {
                    Circle()
                        .fill(activity.color)
                        .frame(width: 8, height: 8)
                        .scaleEffect(timerService.isPaused ? 1.0 : 1.3)
                        .animation(.easeInOut(duration: 0.8).repeatForever(), value: timerService.isPaused)
                    
                    Text(activity.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(timerService.formattedTime)
                        .font(.caption)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(activity.color)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(activity.color.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    // MARK: - Today Preview
    private var todayPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localizationService.localized("today_schedule"))
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(viewModel.todaySchedules, id: \.id) { schedule in
                HStack(spacing: 12) {
                    // Time indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(schedule.activity.color)
                        .frame(width: 4, height: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(schedule.activity.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(schedule.timeRangeString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    statusIcon(for: schedule.completionStatus)
                }
                .padding(.vertical, 4)
            }
        }
        .cardStyle()
    }
    
    private func statusIcon(for status: CompletionStatus) -> some View {
        Group {
            switch status {
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.theme.success)
            case .inProgress:
                Image(systemName: "play.circle.fill")
                    .foregroundStyle(Color.theme.primary)
            case .skipped:
                Image(systemName: "forward.circle.fill")
                    .foregroundStyle(.secondary)
            case .overdue:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Color.theme.error)
            case .pending:
                Image(systemName: "circle")
                    .foregroundStyle(.tertiary)
            }
        }
        .font(.title3)
    }
}
