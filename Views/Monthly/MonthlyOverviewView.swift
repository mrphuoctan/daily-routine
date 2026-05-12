import SwiftUI
import SwiftData

struct MonthlyOverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @State private var selectedMonth = Date()
    @State private var monthData: [Date: DayCompletionData] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Month Navigator
                HStack {
                    Button {
                        withAnimation { changeMonth(-1) }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(Color.theme.primary)
                    }
                    
                    Spacer()
                    
                    Text(selectedMonth, format: .dateTime.month(.wide).year())
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation { changeMonth(1) }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundStyle(Color.theme.primary)
                    }
                }
                .padding(.horizontal, AppConstants.screenPadding)
                
                // Month Summary
                monthSummary
                
                // Calendar Grid
                calendarGrid
                
                // Day breakdown list
                dayBreakdownList
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Monthly Overview")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadMonthData() }
        .onChange(of: selectedMonth) { _, _ in loadMonthData() }
    }
    
    // MARK: - Month Summary
    private var monthSummary: some View {
        let days = Array(monthData.values)
        let totalActivities = days.reduce(0) { $0 + $1.totalCount }
        let completedActivities = days.reduce(0) { $0 + $1.completedCount }
        let avgCompletion = totalActivities > 0 ? Double(completedActivities) / Double(totalActivities) * 100 : 0
        let daysTracked = days.filter { $0.totalCount > 0 }.count
        
        return HStack(spacing: 12) {
            MonthStatCard(title: "Days Tracked", value: "\(daysTracked)", icon: "calendar", color: Color.theme.primary)
            MonthStatCard(title: "Activities", value: "\(totalActivities)", icon: "list.bullet", color: Color.theme.accent)
            MonthStatCard(title: "Completed", value: "\(Int(avgCompletion))%", icon: "checkmark.circle", color: Color.theme.success)
        }
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack(spacing: 4) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar days
            let daysInMonth = daysForCalendar()
            let weeks = stride(from: 0, to: daysInMonth.count, by: 7).map {
                Array(daysInMonth[$0..<min($0 + 7, daysInMonth.count)])
            }
            
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 4) {
                    ForEach(week, id: \.self) { date in
                        if let date = date {
                            let data = monthData[date.startOfDay]
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(colorForDay(data))
                                    .frame(height: 40)
                                
                                VStack(spacing: 1) {
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    if let d = data, d.totalCount > 0 {
                                        Text("\(d.completedCount)/\(d.totalCount)")
                                            .font(.system(size: 7))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Color.clear
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Day Breakdown List
    private var dayBreakdownList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Summary")
                .font(.headline).fontWeight(.bold)
            
            let sortedDays = monthData.sorted { $0.key > $1.key }.prefix(10)
            
            if sortedDays.isEmpty {
                Text("No data for this month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(sortedDays), id: \.key) { date, data in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(data.completedCount)/\(data.totalCount) completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Completion bar
                        let pct = data.totalCount > 0 ? Double(data.completedCount) / Double(data.totalCount) : 0
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray5))
                                .frame(width: 80, height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(pct > 0.7 ? Color.theme.success : pct > 0.4 ? Color.theme.warning : Color.theme.error)
                                .frame(width: 80 * pct, height: 6)
                        }
                        
                        Text("\(Int(pct * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(pct > 0.7 ? Color.theme.success : .secondary)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Helpers
    private func changeMonth(_ delta: Int) {
        selectedMonth = Calendar.current.date(byAdding: .month, value: delta, to: selectedMonth) ?? selectedMonth
    }
    
    private func loadMonthData() {
        let cal = Calendar.current
        let start = selectedMonth.startOfMonth
        let end = cal.date(byAdding: .month, value: 1, to: start) ?? Date()
        
        let descriptor = FetchDescriptor<DailySchedule>(
            predicate: #Predicate<DailySchedule> { s in
                s.date >= start && s.date < end
            }
        )
        
        let schedules = (try? modelContext.fetch(descriptor)) ?? []
        
        var result: [Date: DayCompletionData] = [:]
        for schedule in schedules {
            let day = schedule.date.startOfDay
            var data = result[day] ?? DayCompletionData()
            data.totalCount += 1
            if schedule.completionStatus == .completed {
                data.completedCount += 1
            }
            result[day] = data
        }
        
        monthData = result
    }
    
    private func daysForCalendar() -> [Date?] {
        let cal = Calendar.current
        let start = selectedMonth.startOfMonth
        let firstWeekday = cal.component(.weekday, from: start)
        let daysInMonth = cal.range(of: .day, in: .month, for: start)?.count ?? 30
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in 0..<daysInMonth {
            days.append(cal.date(byAdding: .day, value: day, to: start))
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
    
    private func colorForDay(_ data: DayCompletionData?) -> Color {
        guard let d = data, d.totalCount > 0 else { return Color(.systemGray6) }
        let pct = Double(d.completedCount) / Double(d.totalCount)
        if pct >= 0.8 { return Color.theme.success.opacity(0.3) }
        if pct >= 0.5 { return Color.theme.warning.opacity(0.2) }
        return Color.theme.error.opacity(0.15)
    }
}

struct DayCompletionData: Hashable {
    var totalCount: Int = 0
    var completedCount: Int = 0
}

struct MonthStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.title3).fontWeight(.bold)
            Text(title).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
    }
}
