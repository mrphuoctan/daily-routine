import Foundation

extension Date {
    
    // MARK: - Components
    var hour: Int { Calendar.current.component(.hour, from: self) }
    var minute: Int { Calendar.current.component(.minute, from: self) }
    var weekday: Int { Calendar.current.component(.weekday, from: self) }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // MARK: - Time Helpers
    func timeString(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    func dateString(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    func fullDateTimeString(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    func dayOfWeekString(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    func shortDayString(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    func dayNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    func monthYearString(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    // MARK: - Date Math
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    // MARK: - Time from Components
    static func timeToday(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }
    
    // MARK: - Duration Formatting
    static func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
    
    static func formatDuration(seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        return formatDuration(minutes: totalMinutes)
    }
    
    static func formatTimerDuration(seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}
