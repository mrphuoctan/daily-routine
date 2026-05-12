import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @State private var viewModel = AnalyticsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    summaryCards
                    
                    // Chart Segment Control
                    Picker("Period", selection: $selectedTab) {
                        Text("Weekly").tag(0)
                        Text("Monthly").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppConstants.screenPadding)
                    
                    // Charts
                    if selectedTab == 0 {
                        weeklyChartSection
                    } else {
                        monthlyChartSection
                    }
                    
                    // Planned vs Actual
                    plannedVsActualSection
                    
                    // Daily Timeline Chart
                    dailyTimelineChart
                    
                    // Activity Heatmap
                    activityHeatmap
                    
                    // Sleep Consistency
                    sleepConsistencySection
                    
                    // Burnout Risk
                    burnoutRiskSection
                    
                    // Category Breakdown
                    categoryBreakdown
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(localizationService.localized("tab_analytics"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.loadAnalytics(modelContext: modelContext)
        }
    }
    
    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                SummaryCard(
                    icon: "clock.fill",
                    title: "Total Hours",
                    value: String(format: "%.1fh", viewModel.totalHoursThisWeek),
                    color: Color.theme.primary
                )
                
                SummaryCard(
                    icon: "checkmark.circle.fill",
                    title: "Completion",
                    value: "\(Int(viewModel.completionRate * 100))%",
                    color: Color.theme.success
                )
                
                SummaryCard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(viewModel.streakDays) days",
                    color: Color.theme.accent
                )
                
                SummaryCard(
                    icon: "brain.head.profile",
                    title: "Focus Score",
                    value: "\(Int(viewModel.focusScore))%",
                    color: Color(hex: "AF52DE")
                )
            }
            .padding(.horizontal, AppConstants.screenPadding)
        }
    }
    
    // MARK: - Weekly Bar Chart
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Overview")
                .font(.headline)
                .fontWeight(.bold)
            
            if !viewModel.weeklyData.isEmpty {
                Chart {
                    ForEach(Array(viewModel.weeklyData.sorted { $0.value > $1.value }), id: \.key) { key, value in
                        BarMark(
                            x: .value("Category", key),
                            y: .value("Hours", value)
                        )
                        .foregroundStyle((ActivityType(rawValue: key) ?? .work).color)
                        .cornerRadius(6)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let name = value.as(String.self) {
                                Text(name)
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                            }
                        }
                    }
                }
            } else {
                emptyChartPlaceholder
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Monthly Pie Chart
    private var monthlyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Distribution")
                .font(.headline)
                .fontWeight(.bold)
            
            if !viewModel.monthlyData.isEmpty {
                Chart {
                    ForEach(Array(viewModel.monthlyData.sorted { $0.value > $1.value }), id: \.key) { key, value in
                        SectorMark(
                            angle: .value("Hours", value),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle((ActivityType(rawValue: key) ?? .work).color)
                        .annotation(position: .overlay) {
                            if value > 5 {
                                Text("\(Int(value))h")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .frame(height: 240)
            } else {
                emptyChartPlaceholder
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Planned vs Actual Chart
    private var plannedVsActualSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Planned vs Actual")
                    .font(.headline).fontWeight(.bold)
                Spacer()
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.theme.primary).frame(width: 8, height: 8)
                        Text("Planned").font(.caption2).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.theme.success).frame(width: 8, height: 8)
                        Text("Actual").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            
            if !viewModel.plannedVsActual.isEmpty {
                Chart {
                    ForEach(viewModel.plannedVsActual, id: \.activity) { item in
                        BarMark(
                            x: .value("Activity", item.activity),
                            y: .value("Hours", item.planned)
                        )
                        .foregroundStyle(Color.theme.primary.opacity(0.6))
                        .position(by: .value("Type", "Planned"))
                        
                        BarMark(
                            x: .value("Activity", item.activity),
                            y: .value("Hours", item.actual)
                        )
                        .foregroundStyle(Color.theme.success.opacity(0.8))
                        .position(by: .value("Type", "Actual"))
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let name = value.as(String.self) {
                                Text(name).font(.system(size: 7)).rotationEffect(.degrees(-45))
                            }
                        }
                    }
                }
            } else {
                emptyChartPlaceholder
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Daily Timeline Chart
    private var dailyTimelineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Timeline")
                .font(.headline).fontWeight(.bold)
            
            if !viewModel.todayTimeline.isEmpty {
                VStack(spacing: 2) {
                    ForEach(viewModel.todayTimeline, id: \.activity) { item in
                        HStack(spacing: 8) {
                            Text(item.timeRange)
                                .font(.caption2)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                                .frame(width: 80, alignment: .trailing)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill((ActivityType(rawValue: item.activity) ?? .work).color)
                                .frame(height: max(CGFloat(item.durationMinutes) / 60.0 * 24, 16))
                                .overlay(
                                    Text(item.activity)
                                        .font(.system(size: 9))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .padding(.horizontal, 4)
                                    , alignment: .leading
                                )
                            
                            statusDot(item.status)
                        }
                    }
                }
            } else {
                emptyChartPlaceholder
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Activity Heatmap
    private var activityHeatmap: some View {
        HeatmapView(data: viewModel.heatmapData, weeks: 4)
            .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Sleep Consistency
    private var sleepConsistencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Consistency")
                .font(.headline).fontWeight(.bold)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(viewModel.avgSleepTime)
                        .font(.title3).fontWeight(.bold)
                    Text("Avg Sleep")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text(viewModel.avgWakeTime)
                        .font(.title3).fontWeight(.bold)
                    Text("Avg Wake")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text(String(format: "%.1fh", viewModel.avgSleepDuration))
                        .font(.title3).fontWeight(.bold)
                    Text("Avg Duration")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.sleepConsistencyScore))%")
                        .font(.title3).fontWeight(.bold)
                        .foregroundStyle(viewModel.sleepConsistencyScore >= 80 ? Color.theme.success : Color.theme.warning)
                    Text("Consistency")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    // MARK: - Burnout Risk
    private var burnoutRiskSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Burnout Risk")
                    .font(.headline).fontWeight(.bold)
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: viewModel.burnoutRisk.icon)
                        .foregroundStyle(viewModel.burnoutRisk.color)
                    Text(viewModel.burnoutRisk.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.burnoutRisk.color)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(viewModel.burnoutRisk.color.opacity(0.12))
                .clipShape(Capsule())
            }
            
            // Risk bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(viewModel.burnoutRisk.color)
                        .frame(width: geo.size.width * riskPercent, height: 8)
                }
            }
            .frame(height: 8)
            
            // Work stats
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text(String(format: "%.1fh", viewModel.dailyWorkHours))
                        .font(.subheadline).fontWeight(.bold)
                    Text("Today")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                VStack(spacing: 2) {
                    Text(String(format: "%.0fh", viewModel.weeklyWorkHours))
                        .font(.subheadline).fontWeight(.bold)
                    Text("This Week")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
            
            // Factors
            if !viewModel.burnoutFactors.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.burnoutFactors, id: \.self) { factor in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(viewModel.burnoutRisk.color)
                                .frame(width: 5, height: 5)
                            Text(factor)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.theme.success)
                    Text("No burnout risk factors detected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private var riskPercent: Double {
        switch viewModel.burnoutRisk {
        case .low: return 0.15
        case .moderate: return 0.45
        case .high: return 0.75
        case .critical: return 1.0
        }
    }
    
    // MARK: - Category Breakdown
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .fontWeight(.bold)
            
            let data = selectedTab == 0 ? viewModel.weeklyData : viewModel.monthlyData
            let total = data.values.reduce(0, +)
            
            ForEach(Array(data.sorted { $0.value > $1.value }), id: \.key) { key, value in
                let actType = ActivityType(rawValue: key) ?? .work
                
                HStack(spacing: 12) {
                    Image(systemName: actType.icon)
                        .font(.caption)
                        .foregroundStyle(actType.color)
                        .frame(width: 28, height: 28)
                        .background(actType.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(key)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(actType.color.opacity(0.15))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(actType.color)
                                    .frame(width: total > 0 ? geometry.size.width * (value / total) : 0, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    
                    Text(String(format: "%.1fh", value))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: 44, alignment: .trailing)
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private func statusDot(_ status: String) -> some View {
        Circle()
            .fill(status == "completed" ? Color.theme.success :
                    status == "inProgress" ? Color.theme.primary :
                    status == "skipped" ? Color.theme.textSecondary : Color(.systemGray4))
            .frame(width: 8, height: 8)
    }
    
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            
            Text("No data yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Complete activities to see analytics")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 130, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
    }
}
