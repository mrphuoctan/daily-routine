import Foundation
import SwiftData

@Model
final class EvidencePhoto {
    var id: UUID
    var imageData: Data?
    var caption: String
    var capturedAt: Date
    
    @Relationship var activityLog: ActivityLog?
    
    init(
        imageData: Data? = nil,
        caption: String = "",
        activityLog: ActivityLog? = nil
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.caption = caption
        self.capturedAt = Date()
        self.activityLog = activityLog
    }
}
