import Foundation
import SwiftData
import SwiftUI

@Observable
class DashboardViewModel {
    var todaySchedules: [DailySchedule] = []
    var currentActivity: DailySchedule?
    var nextActivity: DailySchedule?
    var completionPercentage: Double = 0
    var remainingFreeMinutes: Int = 0
    var completedCount: Int = 0
    var totalCount: Int = 0
    
    func loadData(modelContext: ModelContext) {
        let schedules = ScheduleService.getTodaySchedule(modelContext: modelContext)
        
        // Generate if empty
        if schedules.isEmpty {
            let templates = (try? modelContext.fetch(FetchDescriptor<ScheduleTemplate>())) ?? []
            if !templates.isEmpty {
                ScheduleService.generateDailySchedule(for: Date(), templates: templates, modelContext: modelContext)
                todaySchedules = ScheduleService.getTodaySchedule(modelContext: modelContext)
            }
        } else {
            todaySchedules = schedules
        }
        
        currentActivity = ScheduleService.getCurrentActivity(from: todaySchedules)
        nextActivity = ScheduleService.getNextActivity(from: todaySchedules)
        completionPercentage = ScheduleService.completionPercentage(for: todaySchedules)
        remainingFreeMinutes = ScheduleService.remainingFreeTimeMinutes(for: todaySchedules)
        completedCount = todaySchedules.filter { $0.completionStatus == .completed }.count
        totalCount = todaySchedules.count
    }
    
    func checkIn(schedule: DailySchedule) {
        schedule.completionStatus = .inProgress
        schedule.activityLog?.checkIn()
        
        // Auto-set focus music mode based on activity
        MediaControlService.shared.setModeForActivity(schedule.activity)
        MediaControlService.shared.show()
    }
    
    func checkOut(schedule: DailySchedule) {
        schedule.completionStatus = .completed
        schedule.activityLog?.checkOut()
    }
    
    func skipActivity(schedule: DailySchedule) {
        schedule.completionStatus = .skipped
        schedule.activityLog?.completionStatus = .skipped
    }
}
