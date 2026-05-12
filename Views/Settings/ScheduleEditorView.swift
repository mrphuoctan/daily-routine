import SwiftUI
import SwiftData

struct ScheduleEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @State private var templates: [ScheduleTemplate] = []
    @State private var selectedDay: DayOfWeek = .monday
    @State private var showingAddSheet = false
    @State private var editingTemplate: ScheduleTemplate?
    
    var body: some View {
        VStack(spacing: 0) {
            // Day selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        Button {
                            withAnimation { selectedDay = day }
                        } label: {
                            Text(day.shortName)
                                .font(.subheadline)
                                .fontWeight(selectedDay == day ? .bold : .regular)
                                .foregroundStyle(selectedDay == day ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedDay == day ? Color.theme.primary : Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, AppConstants.screenPadding)
                .padding(.vertical, 12)
            }
            
            // Templates for selected day
            List {
                ForEach(filteredTemplates, id: \.id) { template in
                    Button {
                        editingTemplate = template
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(template.activity.color)
                                .frame(width: 4, height: 44)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.activity.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Text("\(template.startTimeString) → \(template.endTimeString) (\(template.durationMinutes)m)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: template.activity.icon)
                                .foregroundStyle(template.activity.color)
                        }
                    }
                }
                .onDelete(perform: deleteTemplates)
            }
            .listStyle(.plain)
        }
        .navigationTitle(localizationService.localized("tab_schedule_editor"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            TemplateFormView(day: selectedDay) { template in
                modelContext.insert(template)
                try? modelContext.save()
                loadTemplates()
            }
        }
        .sheet(item: $editingTemplate) { template in
            TemplateFormView(day: selectedDay, existing: template) { updated in
                template.activityType = updated.activityType
                template.startHour = updated.startHour
                template.startMinute = updated.startMinute
                template.endHour = updated.endHour
                template.endMinute = updated.endMinute
                try? modelContext.save()
                loadTemplates()
            }
        }
        .onAppear { loadTemplates() }
        .onChange(of: selectedDay) { _, _ in }
    }
    
    private var filteredTemplates: [ScheduleTemplate] {
        templates
            .filter { $0.dayOfWeek == selectedDay.rawValue }
            .sorted { $0.startHour * 60 + $0.startMinute < $1.startHour * 60 + $1.startMinute }
    }
    
    private func loadTemplates() {
        templates = (try? modelContext.fetch(FetchDescriptor<ScheduleTemplate>())) ?? []
    }
    
    private func deleteTemplates(at offsets: IndexSet) {
        let toDelete = offsets.map { filteredTemplates[$0] }
        for template in toDelete {
            modelContext.delete(template)
        }
        try? modelContext.save()
        loadTemplates()
    }
}

// MARK: - Template Form (Add/Edit)
struct TemplateFormView: View {
    @Environment(\.dismiss) private var dismiss
    let day: DayOfWeek
    var existing: ScheduleTemplate?
    let onSave: (ScheduleTemplate) -> Void
    
    @State private var selectedActivity: ActivityType = .work
    @State private var startHour: Int = 8
    @State private var startMinute: Int = 0
    @State private var endHour: Int = 9
    @State private var endMinute: Int = 0
    
    init(day: DayOfWeek, existing: ScheduleTemplate? = nil, onSave: @escaping (ScheduleTemplate) -> Void) {
        self.day = day
        self.existing = existing
        self.onSave = onSave
        if let e = existing {
            _selectedActivity = State(initialValue: e.activity)
            _startHour = State(initialValue: e.startHour)
            _startMinute = State(initialValue: e.startMinute)
            _endHour = State(initialValue: e.endHour)
            _endMinute = State(initialValue: e.endMinute)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    Picker("Type", selection: $selectedActivity) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }.tag(type)
                        }
                    }
                }
                
                Section("Start Time") {
                    Stepper("Hour: \(String(format: "%02d", startHour))", value: $startHour, in: 0...23)
                    Stepper("Minute: \(String(format: "%02d", startMinute))", value: $startMinute, in: 0...59, step: 5)
                }
                
                Section("End Time") {
                    Stepper("Hour: \(String(format: "%02d", endHour))", value: $endHour, in: 0...23)
                    Stepper("Minute: \(String(format: "%02d", endMinute))", value: $endMinute, in: 0...59, step: 5)
                }
                
                Section {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(durationText)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(existing == nil ? "Add Template" : "Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let template = ScheduleTemplate(
                            activityType: selectedActivity,
                            dayOfWeek: day,
                            startHour: startHour, startMinute: startMinute,
                            endHour: endHour, endMinute: endMinute
                        )
                        onSave(template)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var durationText: String {
        let startTotal = startHour * 60 + startMinute
        var endTotal = endHour * 60 + endMinute
        if endTotal <= startTotal { endTotal += 24 * 60 }
        let dur = endTotal - startTotal
        return "\(dur / 60)h \(dur % 60)m"
    }
}
