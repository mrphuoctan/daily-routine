import SwiftUI
import SwiftData

struct ActivityHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @State private var viewModel = ActivityHistoryViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterChips
                
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(ActivityHistoryViewModel.Period.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppConstants.screenPadding)
                .padding(.vertical, 8)
                
                if viewModel.logs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray").font(.system(size: 48)).foregroundStyle(.tertiary)
                        Text("No activity logs yet").font(.headline).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity).padding(.top, 80)
                } else {
                    List(viewModel.logs, id: \.id) { log in
                        NavigationLink { ActivityDetailView(log: log) } label: {
                            HStack(spacing: 12) {
                                Image(systemName: log.activity.icon)
                                    .foregroundStyle(log.activity.color)
                                    .frame(width: 36, height: 36)
                                    .background(log.activity.color.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(log.activity.rawValue).font(.subheadline).fontWeight(.semibold)
                                    Text(log.date.dateString(locale: localizationService.locale)).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(Date.formatDuration(minutes: log.actualDurationMinutes ?? log.plannedDurationMinutes)).font(.caption).fontWeight(.semibold)
                                    Text(log.completionStatus.rawValue.capitalized).font(.caption2).foregroundStyle(log.completionStatus.color)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
        }
        .onAppear { viewModel.loadLogs(modelContext: modelContext) }
        .onChange(of: viewModel.selectedPeriod) { _, _ in viewModel.loadLogs(modelContext: modelContext) }
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(label: "All", isSelected: viewModel.selectedFilter == nil, color: Color.theme.primary) {
                    viewModel.selectedFilter = nil
                    viewModel.loadLogs(modelContext: modelContext)
                }
                ForEach(ActivityType.allCases, id: \.self) { type in
                    chipButton(label: type.rawValue, isSelected: viewModel.selectedFilter == type, color: type.color) {
                        viewModel.selectedFilter = type
                        viewModel.loadLogs(modelContext: modelContext)
                    }
                }
            }
            .padding(.horizontal, AppConstants.screenPadding)
            .padding(.vertical, 8)
        }
    }
    
    private func chipButton(label: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption).fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color(.secondarySystemGroupedBackground))
                .foregroundStyle(isSelected ? color : .secondary)
                .clipShape(Capsule())
        }
    }
}
