import SwiftUI

struct TimelineItemView: View {
    let schedule: DailySchedule
    var onCheckIn: () -> Void
    var onCheckOut: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline Column
            VStack(spacing: 0) {
                // Time
                Text(schedule.plannedStartTime.timeString())
                    .font(.caption)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: 48)
                
                // Line & Dot
                VStack(spacing: 0) {
                    Circle()
                        .fill(schedule.isCurrentActivity ? schedule.activity.color : .secondary.opacity(0.3))
                        .frame(width: schedule.isCurrentActivity ? 12 : 8, height: schedule.isCurrentActivity ? 12 : 8)
                        .overlay(
                            Circle()
                                .stroke(schedule.activity.color, lineWidth: 2)
                                .frame(width: 18, height: 18)
                                .opacity(schedule.isCurrentActivity ? 1 : 0)
                                .scaleEffect(schedule.isCurrentActivity ? 1.2 : 0.8)
                                .animation(.easeInOut(duration: 1.2).repeatForever(), value: schedule.isCurrentActivity)
                        )
                    
                    Rectangle()
                        .fill(.secondary.opacity(0.2))
                        .frame(width: 2, height: 40)
                }
            }
            
            // Content Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: schedule.activity.icon)
                        .font(.subheadline)
                        .foregroundStyle(schedule.activity.color)
                    
                    Text(schedule.activity.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(Date.formatDuration(minutes: schedule.plannedDurationMinutes))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Status & Actions
                HStack {
                    Text(schedule.completionStatus.rawValue.capitalized)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(schedule.completionStatus.color.opacity(0.15))
                        .foregroundStyle(schedule.completionStatus.color)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    if schedule.isCurrentActivity {
                        if schedule.completionStatus == .inProgress {
                            Button("Check Out", action: onCheckOut)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.theme.error)
                                .clipShape(Capsule())
                        } else if schedule.completionStatus == .pending {
                            Button("Check In", action: onCheckIn)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(schedule.activity.color)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Actual Time (if available)
                if let log = schedule.activityLog, let actual = log.actualDurationMinutes {
                    HStack {
                        Text("Actual: \(Date.formatDuration(minutes: actual))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        if let diff = log.durationDifferenceMinutes {
                            Text(diff >= 0 ? "+\(diff)m" : "\(diff)m")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(diff >= 0 ? Color.theme.success : Color.theme.error)
                        }
                    }
                }
            }
            .padding(12)
            .background(
                schedule.isCurrentActivity
                ? schedule.activity.color.opacity(0.08)
                : Color(.secondarySystemGroupedBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        schedule.isCurrentActivity ? schedule.activity.color.opacity(0.3) : .clear,
                        lineWidth: 1
                    )
            )
        }
        .padding(.vertical, 4)
    }
}
