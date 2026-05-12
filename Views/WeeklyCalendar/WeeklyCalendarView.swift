import SwiftUI
import SwiftData

struct WeeklyCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @State private var viewModel = WeeklyCalendarViewModel()
    @State private var selectedDate: Date?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Week Navigation
                weekNavigationHeader
                
                // Day Headers
                dayHeaderRow
                
                // Schedule Grid
                ScrollView {
                    scheduleGrid
                        .padding(.horizontal, 8)
                        .padding(.bottom, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(localizationService.localized("tab_weekly"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.loadWeekData(modelContext: modelContext)
        }
    }
    
    // MARK: - Week Navigation
    private var weekNavigationHeader: some View {
        HStack {
            Button {
                viewModel.navigateWeek(forward: false)
                viewModel.loadWeekData(modelContext: modelContext)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            if let first = viewModel.weekDates.first, let last = viewModel.weekDates.last {
                Text("\(first.dateString(locale: localizationService.locale)) — \(last.dateString(locale: localizationService.locale))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Button {
                viewModel.navigateWeek(forward: true)
                viewModel.loadWeekData(modelContext: modelContext)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, AppConstants.screenPadding)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Day Headers
    private var dayHeaderRow: some View {
        HStack(spacing: 4) {
            ForEach(viewModel.weekDates, id: \.self) { date in
                let isToday = date.isToday()
                
                VStack(spacing: 4) {
                    Text(date.shortDayString(locale: localizationService.locale))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text(date.dayNumber())
                        .font(.footnote)
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundStyle(isToday ? .white : .primary)
                        .frame(width: 28, height: 28)
                        .background(isToday ? Color.theme.primary : .clear)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
    
    // MARK: - Schedule Grid
    private var scheduleGrid: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(viewModel.weekDates, id: \.self) { date in
                VStack(spacing: 2) {
                    let schedules = viewModel.schedulesByDate[date.startOfDay] ?? []
                    ForEach(schedules, id: \.id) { schedule in
                        let height = max(CGFloat(schedule.plannedDurationMinutes) / 60.0 * 30, 20)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(schedule.activity.color.opacity(
                                schedule.completionStatus == .completed ? 0.8 : 0.4
                            ))
                            .frame(height: height)
                            .overlay(
                                Text(schedule.activity.rawValue)
                                    .font(.system(size: 7))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .padding(2)
                                , alignment: .topLeading
                            )
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
