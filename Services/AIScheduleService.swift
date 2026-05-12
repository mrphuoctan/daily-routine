import Foundation
import SwiftData

/// AI-powered schedule intelligence using local heuristics
/// Future: Replace heuristics with Core ML models for personalized predictions
class AIScheduleService: ObservableObject {
    static let shared = AIScheduleService()
    
    @Published var suggestions: [ScheduleSuggestion] = []
    @Published var fatigueLevel: FatigueLevel = .normal
    @Published var productivityPrediction: Double = 0
    
    // MARK: - Feature #106: AI Schedule Optimization
    func optimizeSchedule(schedules: [DailySchedule], historicalLogs: [ActivityLog]) -> [ScheduleSuggestion] {
        var suggestions: [ScheduleSuggestion] = []
        
        // Analyze completion patterns by time of day
        let morningLogs = historicalLogs.filter {
            guard let start = $0.actualStartTime else { return false }
            let hour = Calendar.current.component(.hour, from: start)
            return hour < 12
        }
        let afternoonLogs = historicalLogs.filter {
            guard let start = $0.actualStartTime else { return false }
            let hour = Calendar.current.component(.hour, from: start)
            return hour >= 12 && hour < 17
        }
        
        let morningRate = completionRate(morningLogs)
        let afternoonRate = completionRate(afternoonLogs)
        
        if morningRate > afternoonRate + 0.15 {
            suggestions.append(ScheduleSuggestion(
                type: .timeShift,
                title: "Move intense tasks to morning",
                description: "Your morning completion rate (\(Int(morningRate * 100))%) is significantly higher than afternoon (\(Int(afternoonRate * 100))%). Consider scheduling study/work sessions before noon.",
                priority: .high
            ))
        }
        
        // Check for overloaded days
        let grouped = Dictionary(grouping: schedules) { Calendar.current.startOfDay(for: $0.date) }
        for (date, daySchedules) in grouped {
            let totalMinutes = daySchedules.reduce(0) { $0 + $1.plannedDurationMinutes }
            if totalMinutes > 14 * 60 { // More than 14 hours
                suggestions.append(ScheduleSuggestion(
                    type: .overload,
                    title: "Overloaded: \(date.dateString())",
                    description: "You have \(totalMinutes / 60)h planned. Consider reducing to prevent burnout.",
                    priority: .high
                ))
            }
        }
        
        // Check for missing breaks
        let sortedToday = schedules.filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.plannedStartTime < $1.plannedStartTime }
        
        for i in 0..<(sortedToday.count - 1) {
            let gap = sortedToday[i + 1].plannedStartTime.timeIntervalSince(sortedToday[i].plannedEndTime)
            if gap < 0 { // Overlap
                suggestions.append(ScheduleSuggestion(
                    type: .conflict,
                    title: "Schedule overlap detected",
                    description: "\(sortedToday[i].activity.rawValue) and \(sortedToday[i + 1].activity.rawValue) overlap.",
                    priority: .critical
                ))
            }
        }
        
        self.suggestions = suggestions
        return suggestions
    }
    
    // MARK: - Feature #107: Smart Fatigue Detection
    func detectFatigue(recentLogs: [ActivityLog], sleepHours: Double) -> FatigueLevel {
        var score: Double = 0
        
        // Factor 1: Sleep
        if sleepHours < 5 { score += 40 }
        else if sleepHours < 6 { score += 25 }
        else if sleepHours < 7 { score += 10 }
        
        // Factor 2: Recent completion trend (declining = fatigue)
        let last7days = recentLogs.filter {
            $0.date > Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        }
        let rate = completionRate(last7days)
        if rate < 0.4 { score += 30 }
        else if rate < 0.6 { score += 15 }
        
        // Factor 3: Overwork in last 24h
        let last24h = recentLogs.filter {
            guard let end = $0.actualEndTime else { return false }
            return end > Calendar.current.date(byAdding: .hour, value: -24, to: Date())!
        }
        let workHours = last24h.reduce(0.0) { $0 + Double($1.actualDurationMinutes ?? 0) / 60 }
        if workHours > 12 { score += 30 }
        else if workHours > 10 { score += 15 }
        
        let level: FatigueLevel
        if score >= 60 { level = .severe }
        else if score >= 40 { level = .high }
        else if score >= 20 { level = .moderate }
        else { level = .normal }
        
        fatigueLevel = level
        return level
    }
    
    // MARK: - Feature #108: Smart Recovery Suggestions
    func getRecoverySuggestions(fatigue: FatigueLevel) -> [String] {
        switch fatigue {
        case .severe:
            return [
                "🛑 Take a rest day — your body needs recovery",
                "😴 Prioritize 8+ hours of sleep tonight",
                "🧘 Do light stretching or meditation only",
                "📵 Digital detox for 2 hours before bed"
            ]
        case .high:
            return [
                "⚡ Reduce workload by 30% today",
                "🚶 Take a 15-minute walk between tasks",
                "😴 Go to bed 1 hour earlier",
                "🍎 Eat nutritious meals, stay hydrated"
            ]
        case .moderate:
            return [
                "☕ Take regular breaks (5min every 25min)",
                "🎵 Use calming music during focus sessions",
                "🏃 Light exercise to boost energy"
            ]
        case .normal:
            return [
                "✅ You're doing great! Keep up the momentum",
                "💪 Good energy levels — tackle challenging tasks"
            ]
        }
    }
    
    // MARK: - Feature #109: AI Productivity Recommendations
    func getProductivityRecommendations(logs: [ActivityLog]) -> [ScheduleSuggestion] {
        var recs: [ScheduleSuggestion] = []
        
        // Find most productive time
        let hourlyCompletion = Dictionary(grouping: logs.filter { $0.completionStatus == .completed }) {
            Calendar.current.component(.hour, from: $0.actualStartTime ?? $0.plannedStartTime)
        }
        
        if let bestHour = hourlyCompletion.max(by: { $0.value.count < $1.value.count })?.key {
            recs.append(ScheduleSuggestion(
                type: .recommendation,
                title: "Peak productivity: \(bestHour):00-\(bestHour+1):00",
                description: "You complete the most tasks around \(bestHour):00. Schedule important work during this window.",
                priority: .medium
            ))
        }
        
        // Identify underperforming activities
        let byType = Dictionary(grouping: logs) { $0.activityType }
        for (type, typeLogs) in byType {
            let rate = completionRate(typeLogs)
            if rate < 0.3 && typeLogs.count > 3 {
                recs.append(ScheduleSuggestion(
                    type: .recommendation,
                    title: "\(type) needs attention",
                    description: "Only \(Int(rate * 100))% completion rate. Consider shorter sessions or different time slots.",
                    priority: .medium
                ))
            }
        }
        
        return recs
    }
    
    // MARK: - Feature #110: Smart Task Distribution
    func distributeTasksEvenly(templates: [ScheduleTemplate]) -> [ScheduleSuggestion] {
        var suggestions: [ScheduleSuggestion] = []
        
        // Check daily load balance across week
        let byDay = Dictionary(grouping: templates) { $0.dayOfWeek }
        let dailyMinutes = byDay.mapValues { templates in
            templates.reduce(0) { $0 + $1.durationMinutes }
        }
        
        if let max = dailyMinutes.values.max(), let min = dailyMinutes.values.min() {
            if max - min > 180 { // 3+ hours difference
                suggestions.append(ScheduleSuggestion(
                    type: .distribution,
                    title: "Unbalanced weekly load",
                    description: "Lightest day: \(min/60)h, heaviest: \(max/60)h. Consider redistributing.",
                    priority: .low
                ))
            }
        }
        
        return suggestions
    }
    
    // MARK: - Feature #111: Burnout Prediction
    func predictBurnout(weeklyWorkHours: Double, sleepConsistency: Double, completionTrend: [Double]) -> BurnoutPrediction {
        var risk: Double = 0
        
        if weeklyWorkHours > 60 { risk += 0.3 }
        else if weeklyWorkHours > 50 { risk += 0.15 }
        
        if sleepConsistency < 50 { risk += 0.25 }
        else if sleepConsistency < 70 { risk += 0.1 }
        
        // Declining completion trend
        if completionTrend.count >= 3 {
            let recent = completionTrend.suffix(3)
            if let first = recent.first, let last = recent.last, last < first - 0.15 {
                risk += 0.25
            }
        }
        
        let daysUntilBurnout: Int
        if risk > 0.7 { daysUntilBurnout = 3 }
        else if risk > 0.5 { daysUntilBurnout = 7 }
        else if risk > 0.3 { daysUntilBurnout = 14 }
        else { daysUntilBurnout = 30 }
        
        return BurnoutPrediction(riskScore: risk, estimatedDaysUntilBurnout: daysUntilBurnout)
    }
    
    // MARK: - Feature #112: Adaptive Schedule Suggestions
    func generateAdaptiveSchedule(historicalLogs: [ActivityLog], currentTemplates: [ScheduleTemplate]) -> [ScheduleSuggestion] {
        var suggestions: [ScheduleSuggestion] = []
        
        // Find activities that consistently run over time
        let overrunning = historicalLogs.filter {
            guard let diff = $0.durationDifferenceMinutes else { return false }
            return diff > 15 // More than 15 mins over
        }
        
        let overrunByType = Dictionary(grouping: overrunning) { $0.activityType }
        for (type, logs) in overrunByType where logs.count >= 3 {
            let avgOverrun = logs.compactMap { $0.durationDifferenceMinutes }.reduce(0, +) / logs.count
            suggestions.append(ScheduleSuggestion(
                type: .adaptive,
                title: "Extend \(type) by \(avgOverrun)min",
                description: "\(type) consistently runs \(avgOverrun)min over planned time. Adjust template to be more realistic.",
                priority: .medium
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Helpers
    private func completionRate(_ logs: [ActivityLog]) -> Double {
        guard !logs.isEmpty else { return 0 }
        let completed = logs.filter { $0.completionStatus == .completed }.count
        return Double(completed) / Double(logs.count)
    }
}

// MARK: - Data Types

struct ScheduleSuggestion: Identifiable {
    let id = UUID()
    let type: SuggestionType
    let title: String
    let description: String
    let priority: SuggestionPriority
    
    enum SuggestionType {
        case timeShift, overload, conflict, recommendation, distribution, adaptive
        
        var icon: String {
            switch self {
            case .timeShift: return "arrow.left.arrow.right"
            case .overload: return "exclamationmark.triangle.fill"
            case .conflict: return "bolt.trianglebadge.exclamationmark.fill"
            case .recommendation: return "lightbulb.fill"
            case .distribution: return "chart.bar.xaxis"
            case .adaptive: return "wand.and.stars"
            }
        }
    }
    
    enum SuggestionPriority: Int, Comparable {
        case low = 0, medium = 1, high = 2, critical = 3
        static func < (lhs: SuggestionPriority, rhs: SuggestionPriority) -> Bool { lhs.rawValue < rhs.rawValue }
        
        var color: String {
            switch self {
            case .low: return "8E8E93"
            case .medium: return "007AFF"
            case .high: return "FF9500"
            case .critical: return "FF453A"
            }
        }
    }
}

enum FatigueLevel: String {
    case normal = "Normal"
    case moderate = "Moderate"
    case high = "High"
    case severe = "Severe"
    
    var emoji: String {
        switch self {
        case .normal: return "💚"
        case .moderate: return "💛"
        case .high: return "🧡"
        case .severe: return "❤️‍🔥"
        }
    }
}

struct BurnoutPrediction {
    let riskScore: Double // 0.0-1.0
    let estimatedDaysUntilBurnout: Int
    
    var riskLevel: String {
        if riskScore > 0.7 { return "Critical" }
        if riskScore > 0.5 { return "High" }
        if riskScore > 0.3 { return "Moderate" }
        return "Low"
    }
}
