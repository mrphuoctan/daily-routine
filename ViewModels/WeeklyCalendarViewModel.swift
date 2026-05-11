import Foundation
import SwiftData

@Observable
class WeeklyCalendarViewModel {
    var weekDates: [Date] = []
    var schedulesByDate: [Date: [DailySchedule]] = [:]
    var selectedDate: Date = Date()
    
    init() {
        calculateWeekDates()
    }
    
    func calculateWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Monday = 2 in Gregorian
        let daysToMonday = (weekday == 1) ? -6 : (2 - weekday)
        let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)!
        
        weekDates = (0..<7).map { calendar.date(byAdding: .day, value: $0, to: monday)! }
    }
    
    func loadWeekData(modelContext: ModelContext) {
        for date in weekDates {
            let startOfDay = date.startOfDay
            let endOfDay = date.endOfDay
            
            let descriptor = FetchDescriptor<DailySchedule>(
                predicate: #Predicate<DailySchedule> { schedule in
                    schedule.date >= startOfDay && schedule.date <= endOfDay
                },
                sortBy: [SortDescriptor(\.sortOrder)]
            )
            
            let schedules = (try? modelContext.fetch(descriptor)) ?? []
            
            if schedules.isEmpty {
                let templates = (try? modelContext.fetch(FetchDescriptor<ScheduleTemplate>())) ?? []
                ScheduleService.generateDailySchedule(for: date, templates: templates, modelContext: modelContext)
                schedulesByDate[date.startOfDay] = (try? modelContext.fetch(descriptor)) ?? []
            } else {
                schedulesByDate[date.startOfDay] = schedules
            }
        }
    }
    
    func navigateWeek(forward: Bool) {
        let offset = forward ? 7 : -7
        weekDates = weekDates.map { $0.adding(days: offset) }
    }
}
