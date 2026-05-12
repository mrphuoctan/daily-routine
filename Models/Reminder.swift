import Foundation
import SwiftData

@Model
final class ReminderItem {
    var id: UUID
    var title: String
    var body: String
    var activityType: String
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var isWeekdayOnly: Bool
    var isWeekendOnly: Bool
    var minutesBefore: Int // e.g., 10 minutes before
    var createdAt: Date
    var lastTriggeredAt: Date?
    var completedCount: Int
    var snoozedCount: Int
    
    init(
        title: String,
        body: String = "",
        activityType: ActivityType,
        hour: Int,
        minute: Int,
        isEnabled: Bool = true,
        isWeekdayOnly: Bool = false,
        isWeekendOnly: Bool = false,
        minutesBefore: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.activityType = activityType.rawValue
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.isWeekdayOnly = isWeekdayOnly
        self.isWeekendOnly = isWeekendOnly
        self.minutesBefore = minutesBefore
        self.createdAt = Date()
        self.lastTriggeredAt = nil
        self.completedCount = 0
        self.snoozedCount = 0
    }
    
    var activity: ActivityType {
        ActivityType(rawValue: activityType) ?? .work
    }
    
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    func markCompleted() {
        completedCount += 1
        lastTriggeredAt = Date()
    }
    
    func markSnoozed() {
        snoozedCount += 1
        lastTriggeredAt = Date()
    }
}
