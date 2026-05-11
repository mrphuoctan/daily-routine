import Foundation
import SwiftData

@Model
final class ActivityCategory {
    var id: UUID
    var name: String
    var type: String // ActivityCategoryType rawValue
    var iconName: String
    var colorHex: String
    var defaultDurationMinutes: Int
    var notificationsEnabled: Bool
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        type: ActivityCategoryType,
        iconName: String = "",
        colorHex: String = "007AFF",
        defaultDurationMinutes: Int = 60,
        notificationsEnabled: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.type = type.rawValue
        self.iconName = iconName.isEmpty ? type.icon : iconName
        self.colorHex = colorHex
        self.defaultDurationMinutes = defaultDurationMinutes
        self.notificationsEnabled = notificationsEnabled
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var categoryType: ActivityCategoryType {
        ActivityCategoryType(rawValue: type) ?? .work
    }
}
