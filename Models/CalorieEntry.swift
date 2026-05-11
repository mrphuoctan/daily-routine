import Foundation
import SwiftData

@Model
final class CalorieEntry {
    var id: UUID
    var name: String
    var calories: Double // positive = consumed, negative = burned
    var time: Date
    var note: String
    var isConsumed: Bool // true = food, false = exercise
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        calories: Double,
        time: Date = Date(),
        note: String = "",
        isConsumed: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.calories = abs(calories)
        self.time = time
        self.note = note
        self.isConsumed = isConsumed
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var effectiveCalories: Double {
        isConsumed ? calories : -calories
    }
    
    var displayCalories: String {
        let prefix = isConsumed ? "+" : "-"
        return "\(prefix)\(Int(calories)) kcal"
    }
}
