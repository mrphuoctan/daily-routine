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
