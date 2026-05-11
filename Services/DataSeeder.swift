import Foundation
import SwiftData

struct DataSeeder {
    
    static func seedIfNeeded(modelContext: ModelContext) {
        // Check if already seeded
        let descriptor = FetchDescriptor<ScheduleTemplate>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        seedScheduleTemplates(modelContext: modelContext)
        seedCategories(modelContext: modelContext)
        seedDefaultReminders(modelContext: modelContext)
        
        try? modelContext.save()
        
        // Generate today's schedule
        let templates = (try? modelContext.fetch(FetchDescriptor<ScheduleTemplate>())) ?? []
        ScheduleService.generateDailySchedule(for: Date(), templates: templates, modelContext: modelContext)
    }
    
    // MARK: - Schedule Templates from Spec
    private static func seedScheduleTemplates(modelContext: ModelContext) {
        // Weekday schedule (Mon-Fri)
        let weekdaySchedule: [(ActivityType, Int, Int, Int, Int)] = [
            (.sleep,           0,  0,  5,  0),
            (.morningRoutine,  5,  0,  5, 30),
            (.gym,             5, 30,  6, 40),
            (.em,              6, 40,  7, 30),
            (.commute,         7, 30,  8, 30),
            (.work,            8, 30, 11, 30),
            (.lunch,          11, 30, 13,  0),
            (.work,           13,  0, 17, 30),
            (.commute,        17, 30, 18, 30),
            (.eveningRoutine, 18, 30, 19,  0),
            (.hsk,            19,  0, 19, 30),
            (.dinner,         19, 30, 20,  0),
            (.freelancer,     20,  0, 22, 45),
            (.ncpGenAI,       22, 45, 23, 15),
            (.masterDegree,   23, 15, 23, 30),
            (.consoleRelax,   23, 30,  0,  0),
        ]
        
        let weekdays: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday]
        for day in weekdays {
            for (activity, sh, sm, eh, em) in weekdaySchedule {
                let template = ScheduleTemplate(
                    activityType: activity,
                    dayOfWeek: day,
                    startHour: sh, startMinute: sm,
                    endHour: eh, endMinute: em
                )
                modelContext.insert(template)
            }
        }
        
        // Saturday
        let saturdaySchedule: [(ActivityType, Int, Int, Int, Int)] = [
            (.sleep,           0,  0,  6, 20),
            (.morningRoutine,  6, 20,  6, 40),
            (.em,              6, 40,  7, 30),
            (.billiards,       7, 30, 11, 30),
            (.commute,        11, 30, 12,  0),
            (.lunchRest,      12,  0, 13,  0),
            (.masterDegree,   13,  0, 15,  0),
            (.breakTime,      15,  0, 15, 30),
            (.freelancer,     15, 30, 18, 30),
            (.dinner,         18, 30, 19,  0),
            (.hsk,            19,  0, 19, 30),
            (.freeTime,       19, 30, 20,  0),
            (.ncpGenAI,       20,  0, 21,  0),
            (.freelancer,     21,  0, 22,  0),
            (.consoleRelax,   22,  0,  0,  0),
        ]
        
        for (activity, sh, sm, eh, em) in saturdaySchedule {
            let template = ScheduleTemplate(
                activityType: activity,
                dayOfWeek: .saturday,
                startHour: sh, startMinute: sm,
                endHour: eh, endMinute: em
            )
            modelContext.insert(template)
        }
        
        // Sunday
        let sundaySchedule: [(ActivityType, Int, Int, Int, Int)] = [
            (.sleep,           0,  0,  6, 20),
            (.morningRoutine,  6, 20,  6, 40),
            (.masterDegree,    6, 40, 11, 30),
            (.commute,        11, 30, 12,  0),
            (.lunchRest,      12,  0, 13,  0),
            (.freelancer,     13,  0, 15,  0),
            (.breakTime,      15,  0, 15, 30),
            (.freelancer,     15, 30, 18, 30),
            (.freeSocial,     18, 30, 19,  0),
            (.dinner,         19,  0, 19, 30),
            (.freeTime,       19, 30, 20,  0),
            (.ncpGenAI,       20,  0, 21,  0),
            (.freelancer,     21,  0, 22,  0),
            (.consoleRelax,   22,  0,  0,  0),
        ]
        
        for (activity, sh, sm, eh, em) in sundaySchedule {
            let template = ScheduleTemplate(
                activityType: activity,
                dayOfWeek: .sunday,
                startHour: sh, startMinute: sm,
                endHour: eh, endMinute: em
            )
            modelContext.insert(template)
        }
    }
    
    // MARK: - Categories
    private static func seedCategories(modelContext: ModelContext) {
        let categories: [(String, ActivityCategoryType, String, Int)] = [
            ("Work",         .work,         "007AFF", 540),
            ("Study",        .study,        "AF52DE", 120),
            ("Fitness",      .fitness,      "34C759",  70),
            ("Relationship", .relationship, "FF6482",  60),
            ("Relax",        .relax,        "30B0C7",  60),
            ("Commute",      .commute,      "8E8E93",  60),
        ]
        
        for (index, (name, type, color, duration)) in categories.enumerated() {
            let category = ActivityCategory(
                name: name,
                type: type,
                colorHex: color,
                defaultDurationMinutes: duration,
                sortOrder: index
            )
            modelContext.insert(category)
        }
    }
    
    // MARK: - Default Reminders
    private static func seedDefaultReminders(modelContext: ModelContext) {
        let reminders: [(String, String, ActivityType, Int, Int, Bool, Bool, Int)] = [
            ("Time for HSK",               "Start your Chinese study session", .hsk,        19,  0, false, false, 0),
            ("Start Freelancer Session",    "Time to work on freelance projects", .freelancer, 20,  0, true,  false, 0),
            ("Go to sleep",                "Wind down and rest", .sleep,       23, 30, false, false, 0),
            ("Gym starts in 10 minutes",   "Get ready for workout", .gym,         5, 30, true,  false, 10),
            ("Morning Routine",            "Start your day right", .morningRoutine, 5,  0, true,  false, 0),
            ("Commute Home",               "Time to head home", .commute,     17, 30, true,  false, 0),
        ]
        
        for (title, body, activity, h, m, weekdayOnly, weekendOnly, minBefore) in reminders {
            let reminder = ReminderItem(
                title: title,
                body: body,
                activityType: activity,
                hour: h,
                minute: m,
                isWeekdayOnly: weekdayOnly,
                isWeekendOnly: weekendOnly,
                minutesBefore: minBefore
            )
            modelContext.insert(reminder)
        }
    }
}
