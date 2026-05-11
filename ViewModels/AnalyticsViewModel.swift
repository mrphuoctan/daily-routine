import Foundation
import SwiftData

@Observable
class AnalyticsViewModel {
    var weeklyData: [String: Double] = [:]   // category: hours
    var monthlyData: [String: Double] = [:]  // category: hours
    var dailyLogs: [ActivityLog] = []
    var completionRate: Double = 0
    var streakDays: Int = 0
    var totalHoursThisWeek: Double = 0
    var focusScore: Double = 0
    
    // Weekly chart data
    var weeklyChartEntries: [(category: String, hours: Double, color: String)] = []
    // Monthly chart data
    var monthlyChartEntries: [(category: String, hours: Double, color: String)] = []
    
    func loadAnalytics(modelContext: ModelContext) {
        loadWeeklyData(modelContext: modelContext)
        loadMonthlyData(modelContext: modelContext)
        calculateCompletionRate(modelContext: modelContext)
        calculateStreak(modelContext: modelContext)
        calculateFocusScore(modelContext: modelContext)
    }
    
    private func loadWeeklyData(modelContext: ModelContext) {
        let startOfWeek = Date().startOfWeek
        let endOfWeek = startOfWeek.adding(days: 7)
        
        let descriptor = FetchDescriptor<ActivityLog>(
            predicate: #Predicate<ActivityLog> { log in
                log.date >= startOfWeek && log.date < endOfWeek
            }
        )
        
        let logs = (try? modelContext.fetch(descriptor)) ?? []
        
        var categoryHours: [String: Double] = [:]
        for log in logs {
            let minutes = log.actualDurationMinutes ?? log.plannedDurationMinutes
            let hours = Double(minutes) / 60.0
            categoryHours[log.activityType, default: 0] += hours
        }
        
        weeklyData = categoryHours
        totalHoursThisWeek = categoryHours.values.reduce(0, +)
        
        weeklyChartEntries = categoryHours.map { key, value in
            let actType = ActivityType(rawValue: key) ?? .work
            return (category: key, hours: value, color: actType.color.description)
        }.sorted { $0.hours > $1.hours }
    }
    
    private func loadMonthlyData(modelContext: ModelContext) {
        let startOfMonth = Date().startOfMonth
        let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth) ?? Date()
        
        let descriptor = FetchDescriptor<ActivityLog>(
            predicate: #Predicate<ActivityLog> { log in
                log.date >= startOfMonth && log.date < endOfMonth
            }
        )
        
        let logs = (try? modelContext.fetch(descriptor)) ?? []
        
        var categoryHours: [String: Double] = [:]
        for log in logs {
            let minutes = log.actualDurationMinutes ?? log.plannedDurationMinutes
            let hours = Double(minutes) / 60.0
            categoryHours[log.activityType, default: 0] += hours
        }
        
        monthlyData = categoryHours
        monthlyChartEntries = categoryHours.map { key, value in
            let actType = ActivityType(rawValue: key) ?? .work
            return (category: key, hours: value, color: actType.color.description)
        }.sorted { $0.hours > $1.hours }
    }
    
    private func calculateCompletionRate(modelContext: ModelContext) {
        let startOfWeek = Date().startOfWeek
        let endOfWeek = startOfWeek.adding(days: 7)
        
        let descriptor = FetchDescriptor<DailySchedule>(
            predicate: #Predicate<DailySchedule> { s in
                s.date >= startOfWeek && s.date < endOfWeek
            }
        )
        
        let schedules = (try? modelContext.fetch(descriptor)) ?? []
        guard !schedules.isEmpty else {
            completionRate = 0
            return
        }
        
        let completed = schedules.filter { $0.completionStatus == .completed }.count
        completionRate = Double(completed) / Double(schedules.count)
    }
    
    private func calculateStreak(modelContext: ModelContext) {
        var streak = 0
        var checkDate = Date().adding(days: -1) // Start from yesterday
        
        for _ in 0..<365 {
            let start = checkDate.startOfDay
            let end = checkDate.endOfDay
            
            let descriptor = FetchDescriptor<DailySchedule>(
                predicate: #Predicate<DailySchedule> { s in
                    s.date >= start && s.date <= end
                }
            )
            
            let schedules = (try? modelContext.fetch(descriptor)) ?? []
            if schedules.isEmpty { break }
            
            let allCompleted = schedules.allSatisfy { $0.completionStatus == .completed || $0.completionStatus == .skipped }
            if allCompleted {
                streak += 1
            } else {
                break
            }
            
            checkDate = checkDate.adding(days: -1)
        }
        
        streakDays = streak
    }
    
    private func calculateFocusScore(modelContext: ModelContext) {
        // Simple focus score: ratio of actual time vs planned time for completed activities
        let start = Date().startOfDay
        let end = Date().endOfDay
        
        let descriptor = FetchDescriptor<ActivityLog>(
            predicate: #Predicate<ActivityLog> { log in
                log.date >= start && log.date <= end
            }
        )
        
        let logs = (try? modelContext.fetch(descriptor)) ?? []
        let completedLogs = logs.filter { $0.completionStatus == .completed }
        
        guard !completedLogs.isEmpty else {
            focusScore = 0
            return
        }
        
        var totalScore: Double = 0
        for log in completedLogs {
            let planned = Double(log.plannedDurationMinutes)
            let actual = Double(log.actualDurationMinutes ?? log.plannedDurationMinutes)
            if planned > 0 {
                let ratio = min(actual / planned, 1.5) // Cap at 150%
                totalScore += min(ratio, 1.0) // Perfect score is 1.0
            }
        }
        
        focusScore = totalScore / Double(completedLogs.count) * 100
    }
}
