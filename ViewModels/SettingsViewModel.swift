import Foundation
import SwiftData

@Observable
class SettingsViewModel {
    var notificationsEnabled: Bool = true
    var categories: [ActivityCategory] = []
    var reminders: [ReminderItem] = []
    var templates: [ScheduleTemplate] = []
    
    func loadSettings(modelContext: ModelContext) {
        categories = (try? modelContext.fetch(FetchDescriptor<ActivityCategory>(
            sortBy: [SortDescriptor(\.sortOrder)]
        ))) ?? []
        
        reminders = (try? modelContext.fetch(FetchDescriptor<ReminderItem>(
            sortBy: [SortDescriptor(\.hour)]
        ))) ?? []
        
        templates = (try? modelContext.fetch(FetchDescriptor<ScheduleTemplate>(
            sortBy: [SortDescriptor(\.startHour)]
        ))) ?? []
        
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
    }
    
    func toggleNotifications(modelContext: ModelContext) {
        notificationsEnabled.toggle()
        UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
        
        if notificationsEnabled {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                if granted {
                    for reminder in reminders {
                        NotificationService.shared.scheduleFromReminder(reminder)
                    }
                }
            }
        } else {
            NotificationService.shared.removeAllNotifications()
        }
    }
    
    func deleteCategory(_ category: ActivityCategory, modelContext: ModelContext) {
        modelContext.delete(category)
        try? modelContext.save()
        loadSettings(modelContext: modelContext)
    }
    
    func addReminder(_ reminder: ReminderItem, modelContext: ModelContext) {
        modelContext.insert(reminder)
        try? modelContext.save()
        NotificationService.shared.scheduleFromReminder(reminder)
        loadSettings(modelContext: modelContext)
    }
    
    func deleteReminder(_ reminder: ReminderItem, modelContext: ModelContext) {
        NotificationService.shared.removeNotification(id: reminder.id.uuidString)
        modelContext.delete(reminder)
        try? modelContext.save()
        loadSettings(modelContext: modelContext)
    }
    
    func resetAllData(modelContext: ModelContext) {
        // Delete all data
        try? modelContext.delete(model: DailySchedule.self)
        try? modelContext.delete(model: ActivityLog.self)
        try? modelContext.delete(model: CheckInRecord.self)
        try? modelContext.delete(model: EvidencePhoto.self)
        try? modelContext.delete(model: ScheduleTemplate.self)
        try? modelContext.delete(model: ActivityCategory.self)
        try? modelContext.delete(model: ReminderItem.self)
        try? modelContext.delete(model: CalorieEntry.self)
        try? modelContext.delete(model: StatisticsCache.self)
        try? modelContext.save()
        
        // Re-seed
        DataSeeder.seedIfNeeded(modelContext: modelContext)
        loadSettings(modelContext: modelContext)
    }
}
