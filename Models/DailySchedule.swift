import Foundation
import SwiftData

@Model
final class DailySchedule {
    var id: UUID
    var date: Date
    var activityType: String
    var plannedStartTime: Date
    var plannedEndTime: Date
    var status: String // CompletionStatus rawValue
    var sortOrder: Int
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade) var activityLog: ActivityLog?
    
    init(
        date: Date,
        activityType: ActivityType,
        plannedStartTime: Date,
        plannedEndTime: Date,
        status: CompletionStatus = .pending,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.date = date.startOfDay
        self.activityType = activityType.rawValue
        self.plannedStartTime = plannedStartTime
        self.plannedEndTime = plannedEndTime
        self.status = status.rawValue
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }
    
    var activity: ActivityType {
        ActivityType(rawValue: activityType) ?? .work
    }
    
    var completionStatus: CompletionStatus {
        get { CompletionStatus(rawValue: status) ?? .pending }
        set { status = newValue.rawValue }
    }
    
    var plannedDurationMinutes: Int {
        Int(plannedEndTime.timeIntervalSince(plannedStartTime) / 60)
    }
    
    var isCurrentActivity: Bool {
        let now = Date()
        return now >= plannedStartTime && now <= plannedEndTime
    }
    
    var isUpcoming: Bool {
        Date() < plannedStartTime
    }
    
    var isPast: Bool {
        Date() > plannedEndTime
    }
    
    var timeRangeString: String {
        "\(plannedStartTime.timeString()) → \(plannedEndTime.timeString())"
    }
}
