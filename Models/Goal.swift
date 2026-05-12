import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var title: String
    var goalDescription: String
    var category: String // ActivityCategoryType raw
    var targetValue: Double
    var currentValue: Double
    var unit: String
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool
    var createdAt: Date
    
    init(
        title: String,
        description: String = "",
        category: ActivityCategoryType = .work,
        targetValue: Double,
        unit: String = "hours",
        startDate: Date = Date(),
        endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    ) {
        self.id = UUID()
        self.title = title
        self.goalDescription = description
        self.category = category.rawValue
        self.targetValue = targetValue
        self.currentValue = 0
        self.unit = unit
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = false
        self.createdAt = Date()
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    var categoryType: ActivityCategoryType {
        ActivityCategoryType(rawValue: category) ?? .work
    }
    
    var isExpired: Bool {
        Date() > endDate && !isCompleted
    }
    
    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
    }
}
