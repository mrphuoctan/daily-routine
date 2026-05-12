import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @AppStorage("app_color_scheme") private var colorSchemeRaw: String = "system"
    @State private var viewModel = SettingsViewModel()
    @State private var showingResetAlert = false
    @State private var showingAddCategory = false
    @State private var editingCategory: ActivityCategory?
    
    var body: some View {
        List {
            // Appearance
            Section("Appearance") {
                Picker("Theme", selection: $colorSchemeRaw) {
                    HStack { Image(systemName: "iphone"); Text("System") }.tag("system")
                    HStack { Image(systemName: "sun.max.fill"); Text("Light") }.tag("light")
                    HStack { Image(systemName: "moon.fill"); Text("Dark") }.tag("dark")
                }
                .pickerStyle(.automatic)
            }
            
            // Language
            Section(localizationService.localized("settings_language")) {
                ForEach(LocalizationService.Language.allCases, id: \.self) { language in
                    Button {
                        withAnimation { localizationService.currentLanguage = language }
                    } label: {
                        HStack {
                            Text(language.flag)
                            Text(language.displayName).foregroundStyle(.primary)
                            Spacer()
                            if localizationService.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.theme.primary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            
            // Notifications
            Section(localizationService.localized("settings_notifications")) {
                Toggle(isOn: Binding(
                    get: { viewModel.notificationsEnabled },
                    set: { _ in viewModel.toggleNotifications(modelContext: modelContext) }
                )) {
                    Label("Enable Notifications", systemImage: "bell.fill")
                }
                .tint(Color.theme.primary)
                
                if viewModel.notificationsEnabled {
                    ForEach(viewModel.reminders, id: \.id) { reminder in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reminder.title).font(.subheadline)
                                Text(reminder.timeString).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: reminder.activity.icon)
                                .foregroundStyle(reminder.activity.color)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteReminder(viewModel.reminders[index], modelContext: modelContext)
                        }
                    }
                }
            }
            
            // Categories — with CRUD
            Section {
                ForEach(viewModel.categories, id: \.id) { category in
                    Button {
                        editingCategory = category
                    } label: {
                        HStack {
                            Image(systemName: category.iconName)
                                .foregroundStyle(Color(hex: category.colorHex))
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.name).font(.subheadline).foregroundStyle(.primary)
                                Text("\(category.defaultDurationMinutes)m default")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption).foregroundStyle(.tertiary)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteCategory(viewModel.categories[index], modelContext: modelContext)
                    }
                }
            } header: {
                HStack {
                    Text("Activity Categories")
                    Spacer()
                    Button { showingAddCategory = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.theme.primary)
                    }
                }
            }
            
            // Data Management
            Section("Data") {
                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    Label("Reset All Data", systemImage: "trash")
                }
            }
            
            // About
            Section("About") {
                HStack {
                    Text("Version"); Spacer()
                    Text(AppConstants.appVersion).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(localizationService.localized("tab_settings"))
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetAllData(modelContext: modelContext)
            }
        } message: {
            Text("This will delete all schedules, logs, and settings. This cannot be undone.")
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView { name, icon, colorHex, duration in
                let cat = ActivityCategory(name: name, type: .work, colorHex: colorHex, defaultDurationMinutes: duration)
                cat.iconName = icon
                modelContext.insert(cat)
                try? modelContext.save()
                viewModel.loadSettings(modelContext: modelContext)
            }
        }
        .sheet(item: $editingCategory) { category in
            CategoryFormView(existing: category) { name, icon, colorHex, duration in
                category.name = name
                category.iconName = icon
                category.colorHex = colorHex
                category.defaultDurationMinutes = duration
                try? modelContext.save()
                viewModel.loadSettings(modelContext: modelContext)
            }
        }
        .onAppear { viewModel.loadSettings(modelContext: modelContext) }
    }
}

// MARK: - Category Form (Add/Edit)
struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss
    var existing: ActivityCategory?
    let onSave: (String, String, String, Int) -> Void
    
    @State private var name: String = ""
    @State private var iconName: String = "folder.fill"
    @State private var colorHex: String = "007AFF"
    @State private var duration: Int = 60
    
    private let iconOptions = [
        "briefcase.fill", "book.fill", "dumbbell.fill", "figure.run",
        "gamecontroller.fill", "graduationcap.fill", "brain.head.profile",
        "car.fill", "moon.fill", "fork.knife", "cup.and.saucer.fill",
        "person.2.fill", "music.note", "laptopcomputer", "pencil",
        "folder.fill", "heart.fill", "star.fill"
    ]
    
    init(existing: ActivityCategory? = nil, onSave: @escaping (String, String, String, Int) -> Void) {
        self.existing = existing
        self.onSave = onSave
        if let e = existing {
            _name = State(initialValue: e.name)
            _iconName = State(initialValue: e.iconName)
            _colorHex = State(initialValue: e.colorHex)
            _duration = State(initialValue: e.defaultDurationMinutes)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                iconName = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .background(iconName == icon ? Color.theme.primary.opacity(0.2) : Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(iconName == icon ? Color.theme.primary : .secondary)
                            }
                        }
                    }
                }
                
                Section("Color (Hex)") {
                    HStack {
                        Circle()
                            .fill(Color(hex: colorHex))
                            .frame(width: 28, height: 28)
                        TextField("e.g. FF5722", text: $colorHex)
                            .textInputAutocapitalization(.characters)
                    }
                }
                
                Section("Default Duration") {
                    Stepper("\(duration) minutes", value: $duration, in: 5...480, step: 15)
                }
            }
            .navigationTitle(existing == nil ? "New Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !name.isEmpty else { return }
                        onSave(name, iconName, colorHex, duration)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
