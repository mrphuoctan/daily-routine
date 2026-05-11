import Foundation
import SwiftData

@Model
final class StatisticsCache {
    var id: UUID
    var date: Date
    var period: String // "daily", "weekly", "monthly"
    var totalPlannedMinutes: Int
    var totalActualMinutes: Int
    var completionRate: Double
    var streakDays: Int
    var focusScore: Double
    var categorySummaryJSON: String // JSON encoded category breakdown
    var createdAt: Date
    var updatedAt: Date
    
    init(
        date: Date,
        period: String = "daily",
        totalPlannedMinutes: Int = 0,
        totalActualMinutes: Int = 0,
        completionRate: Double = 0,
        streakDays: Int = 0,
        focusScore: Double = 0,
        categorySummaryJSON: String = "{}"
    ) {
        self.id = UUID()
        self.date = date
        self.period = period
        self.totalPlannedMinutes = totalPlannedMinutes
        self.totalActualMinutes = totalActualMinutes
        self.completionRate = completionRate
        self.streakDays = streakDays
        self.focusScore = focusScore
        self.categorySummaryJSON = categorySummaryJSON
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
