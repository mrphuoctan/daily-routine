import Foundation
import SwiftData

@Observable
class CalorieViewModel {
    var entries: [CalorieEntry] = []
    var selectedDate: Date = Date()
    var dailyConsumed: Double = 0
    var dailyBurned: Double = 0
    var dailyNet: Double = 0
    var weeklyTotal: Double = 0
    var monthlyTotal: Double = 0
    
    func loadEntries(modelContext: ModelContext) {
        loadDailyEntries(modelContext: modelContext)
        calculateWeeklySummary(modelContext: modelContext)
        calculateMonthlySummary(modelContext: modelContext)
    }
    
    private func loadDailyEntries(modelContext: ModelContext) {
        let start = selectedDate.startOfDay
        let end = selectedDate.endOfDay
        
        let descriptor = FetchDescriptor<CalorieEntry>(
            predicate: #Predicate<CalorieEntry> { entry in
                entry.time >= start && entry.time <= end
            },
            sortBy: [SortDescriptor(\.time, order: .reverse)]
        )
        
        entries = (try? modelContext.fetch(descriptor)) ?? []
        
        dailyConsumed = entries.filter { $0.isConsumed }.reduce(0) { $0 + $1.calories }
        dailyBurned = entries.filter { !$0.isConsumed }.reduce(0) { $0 + $1.calories }
        dailyNet = dailyConsumed - dailyBurned
    }
    
    private func calculateWeeklySummary(modelContext: ModelContext) {
        let start = Date().startOfWeek
        let end = start.adding(days: 7)
        
        let descriptor = FetchDescriptor<CalorieEntry>(
            predicate: #Predicate<CalorieEntry> { entry in
                entry.time >= start && entry.time < end
            }
        )
        
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        weeklyTotal = entries.reduce(0) { $0 + $1.effectiveCalories }
    }
    
    private func calculateMonthlySummary(modelContext: ModelContext) {
        let start = Date().startOfMonth
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start) ?? Date()
        
        let descriptor = FetchDescriptor<CalorieEntry>(
            predicate: #Predicate<CalorieEntry> { entry in
                entry.time >= start && entry.time < end
            }
        )
        
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        monthlyTotal = entries.reduce(0) { $0 + $1.effectiveCalories }
    }
    
    func addEntry(name: String, calories: Double, isConsumed: Bool, note: String, modelContext: ModelContext) {
        let entry = CalorieEntry(
            name: name,
            calories: calories,
            time: Date(),
            note: note,
            isConsumed: isConsumed
        )
        modelContext.insert(entry)
        try? modelContext.save()
        loadEntries(modelContext: modelContext)
    }
    
    func deleteEntry(_ entry: CalorieEntry, modelContext: ModelContext) {
        modelContext.delete(entry)
        try? modelContext.save()
        loadEntries(modelContext: modelContext)
    }
}
