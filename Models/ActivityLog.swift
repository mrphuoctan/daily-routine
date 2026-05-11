import Foundation
import SwiftData

@Model
final class ActivityLog {
    var id: UUID
    var activityType: String
    var date: Date
    var plannedStartTime: Date
    var plannedEndTime: Date
    var actualStartTime: Date?
    var actualEndTime: Date?
    var status: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var checkInRecords: [CheckInRecord]
    @Relationship(deleteRule: .cascade) var evidencePhotos: [EvidencePhoto]
    
    init(
        activityType: ActivityType,
        date: Date,
        plannedStartTime: Date,
        plannedEndTime: Date,
        status: CompletionStatus = .pending,
        notes: String = ""
    ) {
        self.id = UUID()
        self.activityType = activityType.rawValue
        self.date = date.startOfDay
        self.plannedStartTime = plannedStartTime
        self.plannedEndTime = plannedEndTime
        self.status = status.rawValue
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
        self.checkInRecords = []
        self.evidencePhotos = []
    }
    
    var activity: ActivityType {
        ActivityType(rawValue: activityType) ?? .work
    }
    
    var completionStatus: CompletionStatus {
        get { CompletionStatus(rawValue: status) ?? .pending }
        set {
            status = newValue.rawValue
            updatedAt = Date()
        }
    }
    
    var plannedDurationMinutes: Int {
        Int(plannedEndTime.timeIntervalSince(plannedStartTime) / 60)
    }
    
    var actualDurationMinutes: Int? {
        guard let start = actualStartTime, let end = actualEndTime else { return nil }
        return Int(end.timeIntervalSince(start) / 60)
    }
    
    var durationDifferenceMinutes: Int? {
        guard let actual = actualDurationMinutes else { return nil }
        return actual - plannedDurationMinutes
    }
    
    var isActive: Bool {
        actualStartTime != nil && actualEndTime == nil
    }
    
    func checkIn() {
        actualStartTime = Date()
        completionStatus = .inProgress
    }
    
    func checkOut() {
        actualEndTime = Date()
        completionStatus = .completed
    }
    
    func pause() {
        let record = CheckInRecord(
            checkInTime: actualStartTime ?? Date(),
            checkOutTime: Date(),
            activityLog: self
        )
        checkInRecords.append(record)
    }
    
    func resume() {
        actualStartTime = Date()
        completionStatus = .inProgress
    }
}
