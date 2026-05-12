import Foundation
import SwiftData

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var moodLevel: Int // 1-5
    var energyLevel: Int // 1-5
    var stressLevel: Int // 1-5
    var note: String
    var activities: String // comma-separated activity types
    var createdAt: Date
    
    init(
        date: Date = Date(),
        moodLevel: Int = 3,
        energyLevel: Int = 3,
        stressLevel: Int = 3,
        note: String = "",
        activities: [ActivityType] = []
    ) {
        self.id = UUID()
        self.date = date.startOfDay
        self.moodLevel = moodLevel
        self.energyLevel = energyLevel
        self.stressLevel = stressLevel
        self.note = note
        self.activities = activities.map { $0.rawValue }.joined(separator: ",")
        self.createdAt = Date()
    }
    
    var moodEmoji: String {
        switch moodLevel {
        case 1: return "😢"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "😁"
        default: return "😐"
        }
    }
    
    var energyEmoji: String {
        switch energyLevel {
        case 1: return "🔋"
        case 2: return "🪫"
        case 3: return "⚡"
        case 4: return "💪"
        case 5: return "🚀"
        default: return "⚡"
        }
    }
}
