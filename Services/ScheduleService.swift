import Foundation
import SwiftData

class ScheduleService {
    
    // MARK: - Generate Daily Schedule from Templates
    static func generateDailySchedule(
        for date: Date,
        templates: [ScheduleTemplate],
        modelContext: ModelContext
    ) {
        let dayOfWeek = DayOfWeek.from(date: date)
        let todayTemplates = templates.filter { $0.day == dayOfWeek && $0.isActive }
            .sorted { ($0.startHour * 60 + $0.startMinute) < ($1.startHour * 60 + $1.startMinute) }
        
        for (index, template) in todayTemplates.enumerated() {
            let schedule = DailySchedule(
                date: date,
                activityType: template.activity,
                plannedStartTime: template.startDate(for: date),
                plannedEndTime: template.endDate(for: date),
                sortOrder: index
            )
            
            let log = ActivityLog(
                activityType: template.activity,
                date: date,
                plannedStartTime: template.startDate(for: date),
                plannedEndTime: template.endDate(for: date)
            )
            schedule.activityLog = log
            
            modelContext.insert(schedule)
        }
        
        try? modelContext.save()
    }
    
    // MARK: - Check if schedule exists for date
    static func hasSchedule(for date: Date, modelContext: ModelContext) -> Bool {
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        
        let descriptor = FetchDescriptor<DailySchedule>(
            predicate: #Predicate<DailySchedule> { schedule in
                schedule.date >= startOfDay && schedule.date <= endOfDay
            }
        )
        
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }
    
    // MARK: - Get today's schedule
    static func getTodaySchedule(modelContext: ModelContext) -> [DailySchedule] {
        let startOfDay = Date().startOfDay
        let endOfDay = Date().endOfDay
        
        let descriptor = FetchDescriptor<DailySchedule>(
            predicate: #Predicate<DailySchedule> { schedule in
                schedule.date >= startOfDay && schedule.date <= endOfDay
            },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Current Activity
    static func getCurrentActivity(from schedules: [DailySchedule]) -> DailySchedule? {
        let now = Date()
        return schedules.first { schedule in
            now >= schedule.plannedStartTime && now <= schedule.plannedEndTime
        }
    }
    
    // MARK: - Next Activity
    static func getNextActivity(from schedules: [DailySchedule]) -> DailySchedule? {
        let now = Date()
        return schedules.first { schedule in
            schedule.plannedStartTime > now
        }
    }
    
    // MARK: - Completion Percentage
    static func completionPercentage(for schedules: [DailySchedule]) -> Double {
        guard !schedules.isEmpty else { return 0 }
        let completed = schedules.filter { $0.completionStatus == .completed }.count
        return Double(completed) / Double(schedules.count)
    }
    
    // MARK: - Remaining Free Time
    static func remainingFreeTimeMinutes(for schedules: [DailySchedule]) -> Int {
        let now = Date()
        let remaining = schedules.filter { $0.plannedStartTime > now }
        let totalScheduledMinutes = remaining.reduce(0) { $0 + $1.plannedDurationMinutes }
        
        guard let lastEnd = schedules.last?.plannedEndTime else { return 0 }
        let totalRemainingMinutes = Int(lastEnd.timeIntervalSince(now) / 60)
        
        return max(0, totalRemainingMinutes - totalScheduledMinutes)
    }
}
