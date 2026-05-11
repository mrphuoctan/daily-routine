import Foundation
import SwiftData

@Observable
class ActivityHistoryViewModel {
    var logs: [ActivityLog] = []
    var selectedFilter: ActivityType?
    var selectedPeriod: Period = .week
    
    enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All"
    }
    
    func loadLogs(modelContext: ModelContext) {
        var descriptor = FetchDescriptor<ActivityLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = Date().startOfWeek
        case .month:
            startDate = Date().startOfMonth
        case .all:
            startDate = Date.distantPast
        }
        
        if let filter = selectedFilter {
            let filterValue = filter.rawValue
            descriptor.predicate = #Predicate<ActivityLog> { log in
                log.date >= startDate && log.activityType == filterValue
            }
        } else {
            descriptor.predicate = #Predicate<ActivityLog> { log in
                log.date >= startDate
            }
        }
        
        descriptor.fetchLimit = 100
        logs = (try? modelContext.fetch(descriptor)) ?? []
    }
}
