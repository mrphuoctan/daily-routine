import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localizationService: LocalizationService
    @State private var viewModel = SettingsViewModel()
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Language
                Section(localizationService.localized("settings_language")) {
                    ForEach(LocalizationService.Language.allCases, id: \.self) { language in
                        Button {
                            withAnimation { localizationService.currentLanguage = language }
                        } label: {
                            HStack {
                                Text(language.flag)
                                Text(language.displayName)
                                    .foregroundStyle(.primary)
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
                                    Text(reminder.title)
                                        .font(.subheadline)
                                    Text(reminder.timeString)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
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
                
                // Categories
                Section("Activity Categories") {
                    ForEach(viewModel.categories, id: \.id) { category in
                        HStack {
                            Image(systemName: category.iconName)
                                .foregroundStyle(Color(hex: category.colorHex))
                                .frame(width: 28)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.name)
                                    .font(.subheadline)
                                Text("\(category.defaultDurationMinutes)m default")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
                        Text("Version")
                        Spacer()
                        Text(AppConstants.appVersion)
                            .foregroundStyle(.secondary)
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
        }
        .onAppear { viewModel.loadSettings(modelContext: modelContext) }
    }
}
