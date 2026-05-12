import SwiftUI
import SwiftData
import Charts

struct CalorieView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @State private var viewModel = CalorieViewModel()
    @State private var showingAddSheet = false
    @State private var editingEntry: CalorieEntry?
    @State private var selectedPeriod = 0 // 0=Daily, 1=Weekly, 2=Monthly
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    Text("Daily").tag(0)
                    Text("Weekly").tag(1)
                    Text("Monthly").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppConstants.screenPadding)
                
                // Summary Cards
                calorySummaryCards
                
                // Quick Add Button
                Button { showingAddSheet = true } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Entry")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.theme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, AppConstants.screenPadding)
                
                // Entries List
                todayEntries
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(localizationService.localized("tab_calories"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddSheet) {
            CalorieEntryForm { name, cals, consumed, note in
                viewModel.addEntry(name: name, calories: cals, isConsumed: consumed, note: note, modelContext: modelContext)
            }
        }
        .sheet(item: $editingEntry) { entry in
            CalorieEntryForm(existing: entry) { name, cals, consumed, note in
                entry.name = name
                entry.calories = cals
                entry.isConsumed = consumed
                entry.note = note
                try? modelContext.save()
                viewModel.loadEntries(modelContext: modelContext)
            }
        }
        .onAppear { viewModel.loadEntries(modelContext: modelContext) }
    }
    
    private var calorySummaryCards: some View {
        Group {
            if selectedPeriod == 0 {
                // Daily
                HStack(spacing: 12) {
                    CalorieSummaryCard(title: "Consumed", value: Int(viewModel.dailyConsumed), icon: "fork.knife", color: Color.theme.accent)
                    CalorieSummaryCard(title: "Burned", value: Int(viewModel.dailyBurned), icon: "flame.fill", color: Color.theme.success)
                    CalorieSummaryCard(title: "Net", value: Int(viewModel.dailyNet), icon: "equal.circle.fill", color: Color.theme.primary)
                }
            } else if selectedPeriod == 1 {
                // Weekly
                HStack(spacing: 12) {
                    CalorieSummaryCard(title: "Weekly Net", value: Int(viewModel.weeklyTotal), icon: "calendar", color: Color.theme.primary)
                    CalorieSummaryCard(title: "Daily Avg", value: Int(viewModel.weeklyTotal / 7.0), icon: "chart.line.uptrend.xyaxis", color: Color.theme.accent)
                }
            } else {
                // Monthly
                HStack(spacing: 12) {
                    CalorieSummaryCard(title: "Monthly Net", value: Int(viewModel.monthlyTotal), icon: "calendar.badge.clock", color: Color.theme.primary)
                    CalorieSummaryCard(title: "Daily Avg", value: Int(viewModel.monthlyTotal / 30.0), icon: "chart.line.uptrend.xyaxis", color: Color.theme.accent)
                }
            }
        }
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private var todayEntries: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedPeriod == 0 ? "Today" : selectedPeriod == 1 ? "This Week" : "This Month")
                .font(.headline)
                .fontWeight(.bold)
            
            if viewModel.entries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray").font(.title).foregroundStyle(.tertiary)
                    Text("No entries yet").font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(viewModel.entries, id: \.id) { entry in
                    Button {
                        editingEntry = entry
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: entry.isConsumed ? "fork.knife" : "flame.fill")
                                .foregroundStyle(entry.isConsumed ? Color.theme.accent : Color.theme.success)
                                .frame(width: 32, height: 32)
                                .background((entry.isConsumed ? Color.theme.accent : Color.theme.success).opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.name).font(.subheadline).fontWeight(.medium).foregroundStyle(.primary)
                                HStack(spacing: 4) {
                                    Text(entry.time.timeString()).font(.caption).foregroundStyle(.secondary)
                                    if !entry.note.isEmpty {
                                        Text("• \(entry.note)").font(.caption).foregroundStyle(.tertiary).lineLimit(1)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(entry.displayCalories)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(entry.isConsumed ? Color.theme.accent : Color.theme.success)
                                Image(systemName: "pencil")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteEntry(entry, modelContext: modelContext)
                        } label: { Image(systemName: "trash") }
                    }
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
}

struct CalorieSummaryCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text("\(value)").font(.title3).fontWeight(.bold)
            Text("kcal").font(.caption2).foregroundStyle(.secondary)
            Text(title).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
    }
}
