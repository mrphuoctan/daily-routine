import SwiftUI
import SwiftData

struct GoalView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var goals: [Goal] = []
    @State private var showAddGoal = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Active Goals
                if !activeGoals.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Goals")
                            .font(.headline).fontWeight(.bold)
                        
                        ForEach(activeGoals, id: \.id) { goal in
                            GoalCard(goal: goal, onUpdate: { loadGoals() }, onDelete: { deleteGoal(goal) })
                        }
                    }
                    .padding(.horizontal, AppConstants.screenPadding)
                }
                
                // Completed Goals
                if !completedGoals.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Completed (\(completedGoals.count))")
                            .font(.headline).fontWeight(.bold)
                        
                        ForEach(completedGoals, id: \.id) { goal in
                            GoalCard(goal: goal, onUpdate: { loadGoals() }, onDelete: { deleteGoal(goal) })
                                .opacity(0.7)
                        }
                    }
                    .padding(.horizontal, AppConstants.screenPadding)
                }
                
                if goals.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 48))
                            .foregroundStyle(.tertiary)
                        Text("No Goals Yet")
                            .font(.headline).foregroundStyle(.secondary)
                        Text("Set goals to track your progress")
                            .font(.subheadline).foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddGoal = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            GoalFormSheet { goal in
                modelContext.insert(goal)
                try? modelContext.save()
                loadGoals()
            }
        }
        .onAppear { loadGoals() }
    }
    
    private var activeGoals: [Goal] { goals.filter { !$0.isCompleted } }
    private var completedGoals: [Goal] { goals.filter { $0.isCompleted } }
    
    private func loadGoals() {
        goals = (try? modelContext.fetch(FetchDescriptor<Goal>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))) ?? []
    }
    
    private func deleteGoal(_ goal: Goal) {
        modelContext.delete(goal)
        try? modelContext.save()
        loadGoals()
    }
}

struct GoalCard: View {
    let goal: Goal
    let onUpdate: () -> Void
    let onDelete: () -> Void
    @Environment(\.modelContext) private var modelContext
    @State private var showEdit = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: goal.categoryType.icon)
                    .foregroundStyle(goal.categoryType.color)
                Text(goal.title)
                    .font(.subheadline).fontWeight(.semibold)
                Spacer()
                if goal.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.theme.success)
                } else {
                    Text("\(goal.daysRemaining)d left")
                        .font(.caption2)
                        .foregroundStyle(goal.daysRemaining < 7 ? Color.theme.error : .secondary)
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(goal.categoryType.color)
                        .frame(width: geo.size.width * goal.progress, height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(String(format: "%.1f", goal.currentValue))/\(String(format: "%.0f", goal.targetValue)) \(goal.unit)")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption).fontWeight(.bold)
                    .foregroundStyle(goal.categoryType.color)
            }
        }
        .cardStyle()
        .contextMenu {
            Button { showEdit = true } label: { Label("Edit Progress", systemImage: "pencil") }
            Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
        }
        .sheet(isPresented: $showEdit) {
            GoalProgressSheet(goal: goal) {
                try? modelContext.save()
                onUpdate()
            }
        }
    }
}

struct GoalFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Goal) -> Void
    @State private var title = ""
    @State private var description = ""
    @State private var targetValue: Double = 10
    @State private var unit = "hours"
    @State private var category: ActivityCategoryType = .work
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    Picker("Category", selection: $category) {
                        ForEach(ActivityCategoryType.allCases, id: \.self) { cat in
                            HStack { Image(systemName: cat.icon); Text(cat.rawValue) }.tag(cat)
                        }
                    }
                }
                Section("Target") {
                    HStack {
                        Text("Target")
                        Spacer()
                        TextField("Value", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Unit", selection: $unit) {
                        ForEach(["hours", "sessions", "pages", "items", "km"], id: \.self) { Text($0) }
                    }
                    DatePicker("Deadline", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let goal = Goal(title: title, description: description, category: category, targetValue: targetValue, unit: unit, endDate: endDate)
                        onSave(goal)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct GoalProgressSheet: View {
    let goal: Goal
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var addValue: Double = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section { Text("\(goal.title)").font(.headline) }
                Section("Add Progress") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Value", value: $addValue, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        Text(goal.unit).foregroundStyle(.secondary)
                    }
                }
                Section {
                    Text("Current: \(String(format: "%.1f", goal.currentValue)) → \(String(format: "%.1f", goal.currentValue + addValue)) / \(String(format: "%.0f", goal.targetValue))")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        goal.currentValue += addValue
                        if goal.currentValue >= goal.targetValue { goal.isCompleted = true }
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}
