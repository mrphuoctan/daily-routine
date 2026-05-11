import Foundation
import SwiftData

@Model
final class ScheduleTemplate {
    var id: UUID
    var activityType: String // ActivityType rawValue
    var dayOfWeek: Int // DayOfWeek rawValue
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        activityType: ActivityType,
        dayOfWeek: DayOfWeek,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        isActive: Bool = true
    ) {
        self.id = UUID()
        self.activityType = activityType.rawValue
        self.dayOfWeek = dayOfWeek.rawValue
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var activity: ActivityType {
        ActivityType(rawValue: activityType) ?? .work
    }
    
    var day: DayOfWeek {
        DayOfWeek(rawValue: dayOfWeek) ?? .monday
    }
    
    var startTimeString: String {
        String(format: "%02d:%02d", startHour, startMinute)
    }
    
    var endTimeString: String {
        String(format: "%02d:%02d", endHour, endMinute)
    }
    
    var durationMinutes: Int {
        let startTotal = startHour * 60 + startMinute
        var endTotal = endHour * 60 + endMinute
        if endTotal <= startTotal {
            endTotal += 24 * 60 // crosses midnight
        }
        return endTotal - startTotal
    }
    
    func startDate(for date: Date) -> Date {
        Date.timeToday(hour: startHour, minute: startMinute)
    }
    
    func endDate(for date: Date) -> Date {
        var end = Date.timeToday(hour: endHour, minute: endMinute)
        if end <= startDate(for: date) {
            end = end.adding(days: 1)
        }
        return end
    }
}
