import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @EnvironmentObject var timerService: TimerService
    @State private var viewModel = DashboardViewModel()
    @State private var showingActivityDetail = false
    @State private var selectedSchedule: DailySchedule?
    @State private var showingExtendSheet = false
    @State private var showingAdjustSheet = false
    @State private var adjustTarget: DailySchedule?
    
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
                            onResume: { timerService.resume() },
                            onExtend: {
                                adjustTarget = current
                                showingExtendSheet = true
                            },
                            onAdjustTime: {
                                adjustTarget = current
                                showingAdjustSheet = true
                            }
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
        .sheet(isPresented: $showingExtendSheet) {
            if let target = adjustTarget {
                ExtendActivitySheet(schedule: target) {
                    viewModel.loadData(modelContext: modelContext)
                }
            }
        }
        .sheet(isPresented: $showingAdjustSheet) {
            if let target = adjustTarget {
                ManualTimeAdjustSheet(schedule: target) {
                    viewModel.loadData(modelContext: modelContext)
                }
            }
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

// MARK: - Extend Activity Sheet
struct ExtendActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    let schedule: DailySchedule
    let onDone: () -> Void
    @State private var extendMinutes: Int = 15
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(hex: "AF52DE"))
                
                Text("Extend \(schedule.activity.rawValue)")
                    .font(.title3).fontWeight(.bold)
                
                Text("Current: \(schedule.timeRangeString)")
                    .font(.subheadline).foregroundStyle(.secondary)
                
                Stepper("Add \(extendMinutes) minutes", value: $extendMinutes, in: 5...120, step: 5)
                    .padding(.horizontal, 40)
                
                Button {
                    schedule.plannedEndTime = schedule.plannedEndTime.addingTimeInterval(Double(extendMinutes) * 60)
                    onDone()
                    dismiss()
                } label: {
                    Text("Extend by \(extendMinutes)m")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "AF52DE"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Extend Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Manual Time Adjustment Sheet
struct ManualTimeAdjustSheet: View {
    @Environment(\.dismiss) private var dismiss
    let schedule: DailySchedule
    let onDone: () -> Void
    @State private var actualStart: Date = Date()
    @State private var actualEnd: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    HStack {
                        Image(systemName: schedule.activity.icon)
                            .foregroundStyle(schedule.activity.color)
                        Text(schedule.activity.rawValue).fontWeight(.medium)
                    }
                }
                
                Section("Actual Time") {
                    DatePicker("Start", selection: $actualStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $actualEnd, displayedComponents: .hourAndMinute)
                }
                
                Section("Planned") {
                    Text(schedule.timeRangeString)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Adjust Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        schedule.activityLog?.actualStartTime = actualStart
                        schedule.activityLog?.actualEndTime = actualEnd
                        onDone()
                        dismiss()
                    }
                }
            }
            .onAppear {
                actualStart = schedule.activityLog?.actualStartTime ?? Date()
                actualEnd = schedule.activityLog?.actualEndTime ?? Date()
            }
        }
    }
}
