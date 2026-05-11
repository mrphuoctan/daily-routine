import Foundation
import SwiftData

@Model
final class CheckInRecord {
    var id: UUID
    var checkInTime: Date
    var checkOutTime: Date?
    var durationSeconds: Double
    var createdAt: Date
    
    @Relationship var activityLog: ActivityLog?
    
    init(
        checkInTime: Date,
        checkOutTime: Date? = nil,
        activityLog: ActivityLog? = nil
    ) {
        self.id = UUID()
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.durationSeconds = 0
        self.createdAt = Date()
        self.activityLog = activityLog
        
        if let end = checkOutTime {
            self.durationSeconds = end.timeIntervalSince(checkInTime)
        }
    }
    
    var durationMinutes: Int {
        Int(durationSeconds / 60)
    }
    
    var isActive: Bool {
        checkOutTime == nil
    }
    
    func complete() {
        checkOutTime = Date()
        durationSeconds = checkOutTime!.timeIntervalSince(checkInTime)
    }
}
