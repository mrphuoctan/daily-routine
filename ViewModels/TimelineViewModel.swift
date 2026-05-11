import Foundation
import SwiftData

@Observable
class TimelineViewModel {
    var schedules: [DailySchedule] = []
    var selectedDate: Date = Date()
    
    func loadSchedules(for date: Date, modelContext: ModelContext) {
        selectedDate = date
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        
        let descriptor = FetchDescriptor<DailySchedule>(
            predicate: #Predicate<DailySchedule> { schedule in
                schedule.date >= startOfDay && schedule.date <= endOfDay
            },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        
        schedules = (try? modelContext.fetch(descriptor)) ?? []
        
        // Generate if empty
        if schedules.isEmpty {
            let templates = (try? modelContext.fetch(FetchDescriptor<ScheduleTemplate>())) ?? []
            if !templates.isEmpty {
                ScheduleService.generateDailySchedule(for: date, templates: templates, modelContext: modelContext)
                schedules = (try? modelContext.fetch(descriptor)) ?? []
            }
        }
    }
}
