import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    // MARK: - Schedule Notification
    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int,
        weekday: Int? = nil,
        minutesBefore: Int = 0
    ) {
        let content = UNMutableNotificationContent()
        // Use localized text if available
        let locService = LocalizationService.shared
        content.title = locService.localizedNotification(title)
        content.body = locService.localizedNotification(body)
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        // Add snooze action category
        content.categoryIdentifier = "ACTIVITY_REMINDER"
        
        var dateComponents = DateComponents()
        var totalMinutes = hour * 60 + minute - minutesBefore
        if totalMinutes < 0 { totalMinutes += 24 * 60 }
        dateComponents.hour = totalMinutes / 60
        dateComponents.minute = totalMinutes % 60
        
        if let weekday = weekday {
            dateComponents.weekday = weekday
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    // MARK: - Register Notification Categories (snooze action)
    func registerCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: LocalizationService.shared.localizedNotification("Snooze 5m"),
            options: []
        )
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: LocalizationService.shared.localizedNotification("Done"),
            options: .destructive
        )
        
        let category = UNNotificationCategory(
            identifier: "ACTIVITY_REMINDER",
            actions: [snoozeAction, completeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - Schedule from Reminder
    func scheduleFromReminder(_ reminder: ReminderItem) {
        guard reminder.isEnabled else {
            removeNotification(id: reminder.id.uuidString)
            return
        }
        
        if reminder.isWeekdayOnly {
            for day in [2, 3, 4, 5, 6] { // Mon-Fri
                scheduleNotification(
                    id: "\(reminder.id.uuidString)_\(day)",
                    title: reminder.title,
                    body: reminder.body,
                    hour: reminder.hour,
                    minute: reminder.minute,
                    weekday: day,
                    minutesBefore: reminder.minutesBefore
                )
            }
        } else if reminder.isWeekendOnly {
            for day in [1, 7] { // Sun, Sat
                scheduleNotification(
                    id: "\(reminder.id.uuidString)_\(day)",
                    title: reminder.title,
                    body: reminder.body,
                    hour: reminder.hour,
                    minute: reminder.minute,
                    weekday: day,
                    minutesBefore: reminder.minutesBefore
                )
            }
        } else {
            scheduleNotification(
                id: reminder.id.uuidString,
                title: reminder.title,
                body: reminder.body,
                hour: reminder.hour,
                minute: reminder.minute,
                minutesBefore: reminder.minutesBefore
            )
        }
    }
    
    // MARK: - Remove
    func removeNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Snooze
    func snoozeNotification(
        id: String,
        title: String,
        body: String,
        snoozeMinutes: Int = 5
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(snoozeMinutes * 60),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "\(id)_snooze",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
