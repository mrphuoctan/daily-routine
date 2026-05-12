import Foundation
import SwiftUI
import SwiftData

// MARK: - Data structs for charts
struct PlannedVsActualItem {
    let activity: String
    let planned: Double
    let actual: Double
}

struct TimelineChartItem {
    let activity: String
    let timeRange: String
    let durationMinutes: Int
    let status: String
}

@Observable
class AnalyticsViewModel {
    var weeklyData: [String: Double] = [:]   // category: hours
    var monthlyData: [String: Double] = [:]  // category: hours
    var dailyLogs: [ActivityLog] = []
    var completionRate: Double = 0
    var streakDays: Int = 0
    var totalHoursThisWeek: Double = 0
    var focusScore: Double = 0
    
    // Planned vs Actual
    var plannedVsActual: [PlannedVsActualItem] = []
    
    // Daily Timeline
    var todayTimeline: [TimelineChartItem] = []
    
    // Heatmap: [date: completionRate]
    var heatmapData: [Date: Double] = [:]
    
    // Sleep Consistency
    var avgSleepTime: String = "--:--"
    var avgWakeTime: String = "--:--"
    var avgSleepDuration: Double = 0
    var sleepConsistencyScore: Double = 0
    
    // Burnout Detection
    var burnoutRisk: BurnoutLevel = .low
    var burnoutFactors: [String] = []
    var dailyWorkHours: Double = 0
    var weeklyWorkHours: Double = 0
    
    // Weekly/Monthly chart data
    var weeklyChartEntries: [(category: String, hours: Double, color: String)] = []
    var monthlyChartEntries: [(category: String, hours: Double, color: String)] = []
    
    func loadAnalytics(modelContext: ModelContext) {
        loadWeeklyData(modelContext: modelContext)
        loadMonthlyData(modelContext: modelContext)
        calculateCompletionRate(modelContext: modelContext)
        calculateStreak(modelContext: modelContext)
        calculateFocusScore(modelContext: modelContext)
        loadPlannedVsActual(modelContext: modelContext)
        loadTodayTimeline(modelContext: modelContext)
        loadHeatmapData(modelContext: modelContext)
        loadSleepConsistency(modelContext: modelContext)
        detectBurnoutRisk(modelContext: modelContext)
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
        var checkDate = Date().adding(days: -1)
        
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
                let ratio = min(actual / planned, 1.5)
                totalScore += min(ratio, 1.0)
            }
        }
        
        focusScore = totalScore / Double(completedLogs.count) * 100
    }
    
    // MARK: - Planned vs Actual
    private func loadPlannedVsActual(modelContext: ModelContext) {
        let start = Date().startOfWeek
        let end = start.adding(days: 7)
        
        let descriptor = FetchDescriptor<ActivityLog>(
            predicate: #Predicate<ActivityLog> { log in
                log.date >= start && log.date < end
            }
        )
        
        let logs = (try? modelContext.fetch(descriptor)) ?? []
        
        var planned: [String: Double] = [:]
        var actual: [String: Double] = [:]
        
        for log in logs {
            planned[log.activityType, default: 0] += Double(log.plannedDurationMinutes) / 60.0
            actual[log.activityType, default: 0] += Double(log.actualDurationMinutes ?? 0) / 60.0
        }
        
        plannedVsActual = planned.map { key, pVal in
            PlannedVsActualItem(activity: key, planned: pVal, actual: actual[key] ?? 0)
        }.sorted { $0.planned > $1.planned }
    }
    
    // MARK: - Today Timeline
    private func loadTodayTimeline(modelContext: ModelContext) {
        let start = Date().startOfDay
        let end = Date().endOfDay
        
        let descriptor = FetchDescriptor<DailySchedule>(
            predicate: #Predicate<DailySchedule> { s in
                s.date >= start && s.date <= end
            },
            sortBy: [SortDescriptor(\.plannedStartTime)]
        )
        
        let schedules = (try? modelContext.fetch(descriptor)) ?? []
        
        todayTimeline = schedules.map { s in
            TimelineChartItem(
                activity: s.activity.rawValue,
                timeRange: s.timeRangeString,
                durationMinutes: s.plannedDurationMinutes,
                status: s.completionStatus.rawValue
            )
        }
    }
    
    // MARK: - Heatmap (last 30 days)
    private func loadHeatmapData(modelContext: ModelContext) {
        var result: [Date: Double] = [:]
        
        for daysAgo in 0..<30 {
            let date = Date().adding(days: -daysAgo)
            let start = date.startOfDay
            let end = date.endOfDay
            
            let descriptor = FetchDescriptor<DailySchedule>(
                predicate: #Predicate<DailySchedule> { s in
                    s.date >= start && s.date <= end
                }
            )
            
            let schedules = (try? modelContext.fetch(descriptor)) ?? []
            let total = max(schedules.count, 1)
            let completed = schedules.filter { $0.completionStatus == .completed }.count
            result[date.startOfDay] = Double(completed) / Double(total)
        }
        
        heatmapData = result
    }
    
    // MARK: - Sleep Consistency
    private func loadSleepConsistency(modelContext: ModelContext) {
        var sleepTimes: [Int] = []   // minutes from midnight
        var wakeTimes: [Int] = []
        var durations: [Double] = []
        
        for daysAgo in 0..<7 {
            let date = Date().adding(days: -daysAgo)
            let start = date.startOfDay
            let end = date.endOfDay
            
            let descriptor = FetchDescriptor<DailySchedule>(
                predicate: #Predicate<DailySchedule> { s in
                    s.date >= start && s.date <= end
                }
            )
            
            let schedules = (try? modelContext.fetch(descriptor)) ?? []
            let sleepSchedules = schedules.filter { $0.activity == .sleep }
            
            if let firstSleep = sleepSchedules.first {
                let cal = Calendar.current
                let startComps = cal.dateComponents([.hour, .minute], from: firstSleep.plannedStartTime)
                sleepTimes.append((startComps.hour ?? 0) * 60 + (startComps.minute ?? 0))
                let totalSleepMin = sleepSchedules.reduce(0) { $0 + $1.plannedDurationMinutes }
                durations.append(Double(totalSleepMin) / 60.0)
                
                if let lastSleep = sleepSchedules.last {
                    let endComps = cal.dateComponents([.hour, .minute], from: lastSleep.plannedEndTime)
                    wakeTimes.append((endComps.hour ?? 0) * 60 + (endComps.minute ?? 0))
                }
            }
        }
        
        if !sleepTimes.isEmpty {
            let avgSleepMin = sleepTimes.reduce(0, +) / sleepTimes.count
            avgSleepTime = String(format: "%02d:%02d", avgSleepMin / 60, avgSleepMin % 60)
        }
        
        if !wakeTimes.isEmpty {
            let avgWakeMin = wakeTimes.reduce(0, +) / wakeTimes.count
            avgWakeTime = String(format: "%02d:%02d", avgWakeMin / 60, avgWakeMin % 60)
        }
        
        if !durations.isEmpty {
            avgSleepDuration = durations.reduce(0, +) / Double(durations.count)
        }
        
        // Consistency: low variance = high score
        if sleepTimes.count > 1 {
            let mean = Double(sleepTimes.reduce(0, +)) / Double(sleepTimes.count)
            let variance = sleepTimes.map { pow(Double($0) - mean, 2) }.reduce(0, +) / Double(sleepTimes.count)
            let stdDev = variance.squareRoot()
            // 0 stddev = 100%, 60min stddev = 0%
            sleepConsistencyScore = max(0, min(100, (1.0 - stdDev / 60.0) * 100))
        } else {
            sleepConsistencyScore = 100
        }
    }
    
    // MARK: - Burnout Risk Detection
    private func detectBurnoutRisk(modelContext: ModelContext) {
        var factors: [String] = []
        var riskScore: Double = 0
        
        // Factor 1: Weekly work hours (Work + Freelancer) > 60h = high risk
        let workCategories = ["Work", "Freelancer", "Work / Lunch"]
        let weeklyWork = workCategories.reduce(0.0) { $0 + (weeklyData[$1] ?? 0) }
        weeklyWorkHours = weeklyWork
        
        if weeklyWork > 70 {
            riskScore += 40
            factors.append("⚠️ Extreme work: \(Int(weeklyWork))h/week (>70h)")
        } else if weeklyWork > 60 {
            riskScore += 25
            factors.append("⚠️ Heavy work: \(Int(weeklyWork))h/week (>60h)")
        } else if weeklyWork > 50 {
            riskScore += 10
            factors.append("Work hours elevated: \(Int(weeklyWork))h/week")
        }
        
        // Factor 2: Sleep deprivation (<6h average)
        if avgSleepDuration > 0 && avgSleepDuration < 5 {
            riskScore += 30
            factors.append("⚠️ Severe sleep deprivation: \(String(format: "%.1f", avgSleepDuration))h avg")
        } else if avgSleepDuration > 0 && avgSleepDuration < 6 {
            riskScore += 15
            factors.append("Sleep deficit: \(String(format: "%.1f", avgSleepDuration))h avg")
        }
        
        // Factor 3: Low completion rate (<50%)
        if completionRate < 0.3 {
            riskScore += 20
            factors.append("Very low completion: \(Int(completionRate * 100))%")
        } else if completionRate < 0.5 {
            riskScore += 10
            factors.append("Low completion: \(Int(completionRate * 100))%")
        }
        
        // Factor 4: Sleep inconsistency
        if sleepConsistencyScore < 50 {
            riskScore += 15
            factors.append("Irregular sleep pattern: \(Int(sleepConsistencyScore))% consistency")
        }
        
        // Factor 5: No rest/relax time
        let relaxHours = (weeklyData["Console / Relax"] ?? 0) + (weeklyData["Free Time"] ?? 0) + (weeklyData["Break"] ?? 0)
        if relaxHours < 5 {
            riskScore += 15
            factors.append("Insufficient rest: only \(String(format: "%.1f", relaxHours))h/week")
        }
        
        // Determine risk level
        if riskScore >= 60 {
            burnoutRisk = .critical
        } else if riskScore >= 40 {
            burnoutRisk = .high
        } else if riskScore >= 20 {
            burnoutRisk = .moderate
        } else {
            burnoutRisk = .low
        }
        
        burnoutFactors = factors
        
        // Calculate daily work hours from today's data
        let todayWork = todayTimeline.filter { workCategories.contains($0.activity) }
        dailyWorkHours = Double(todayWork.reduce(0) { $0 + $1.durationMinutes }) / 60.0
    }
}

// MARK: - Burnout Level
enum BurnoutLevel: String {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case critical = "Critical"
    
    var color: Color {
        switch self {
        case .low: return Color(hex: "34C759")
        case .moderate: return Color(hex: "FF9500")
        case .high: return Color(hex: "FF3B30")
        case .critical: return Color(hex: "AF52DE")
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "heart.fill"
        case .moderate: return "exclamationmark.triangle"
        case .high: return "exclamationmark.triangle.fill"
        case .critical: return "flame.fill"
        }
    }
}
