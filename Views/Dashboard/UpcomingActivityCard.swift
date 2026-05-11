import SwiftUI

struct UpcomingActivityCard: View {
    let schedule: DailySchedule
    
    var body: some View {
        HStack(spacing: 16) {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(schedule.activity.color)
                .frame(width: 4, height: 56)
            
            // Icon
            Image(systemName: schedule.activity.icon)
                .font(.title3)
                .foregroundStyle(schedule.activity.color)
                .frame(width: 40, height: 40)
                .background(schedule.activity.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("NEXT")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
                
                Text(schedule.activity.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(schedule.timeRangeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Countdown
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeUntilStart)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(schedule.activity.color)
                
                Text("until start")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }
    
    private var timeUntilStart: String {
        let minutes = Int(schedule.plannedStartTime.timeIntervalSince(Date()) / 60)
        if minutes < 0 { return "Now" }
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}
