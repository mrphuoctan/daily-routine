import SwiftUI
import SwiftData

struct DailyTimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @EnvironmentObject var timerService: TimerService
    @State private var viewModel = TimelineViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date Picker Strip
                datePickerStrip
                
                // Timeline
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.schedules, id: \.id) { schedule in
                            TimelineItemView(
                                schedule: schedule,
                                onCheckIn: {
                                    schedule.completionStatus = .inProgress
                                    schedule.activityLog?.checkIn()
                                    timerService.start(activity: schedule.activity)
                                },
                                onCheckOut: {
                                    schedule.completionStatus = .completed
                                    schedule.activityLog?.checkOut()
                                    _ = timerService.stop()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppConstants.screenPadding)
                    .padding(.vertical, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(localizationService.localized("tab_timeline"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.loadSchedules(for: selectedDate, modelContext: modelContext)
        }
        .onChange(of: selectedDate) { _, newDate in
            viewModel.loadSchedules(for: newDate, modelContext: modelContext)
        }
    }
    
    // MARK: - Date Picker Strip
    private var datePickerStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(-3..<4, id: \.self) { offset in
                    let date = Date().adding(days: offset)
                    let isSelected = date.isSameDay(as: selectedDate)
                    
                    Button {
                        withAnimation(AppConstants.defaultAnimation) {
                            selectedDate = date
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(date.shortDayString(locale: localizationService.locale))
                                .font(.caption2)
                                .fontWeight(.medium)
                            
                            Text(date.dayNumber())
                                .font(.title3)
                                .fontWeight(isSelected ? .bold : .regular)
                        }
                        .frame(width: 48, height: 64)
                        .background(
                            isSelected
                            ? AnyShapeStyle(Color.theme.primary)
                            : AnyShapeStyle(Color.clear)
                        )
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, AppConstants.screenPadding)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }
}
