import SwiftUI

struct QuickActionsView: View {
    let schedule: DailySchedule
    var onCheckIn: () -> Void
    var onCheckOut: () -> Void
    var onSkip: () -> Void
    var onPause: () -> Void
    var onResume: () -> Void
    
    @EnvironmentObject var timerService: TimerService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            HStack(spacing: 12) {
                if schedule.completionStatus == .pending {
                    QuickActionButton(
                        icon: "play.fill",
                        label: "Start",
                        color: Color.theme.success,
                        action: onCheckIn
                    )
                }
                
                if schedule.completionStatus == .inProgress {
                    if timerService.isPaused {
                        QuickActionButton(
                            icon: "play.fill",
                            label: "Resume",
                            color: Color.theme.primary,
                            action: onResume
                        )
                    } else {
                        QuickActionButton(
                            icon: "pause.fill",
                            label: "Pause",
                            color: Color.theme.warning,
                            action: onPause
                        )
                    }
                    
                    QuickActionButton(
                        icon: "stop.fill",
                        label: "Complete",
                        color: Color.theme.success,
                        action: onCheckOut
                    )
                }
                
                if schedule.completionStatus != .completed && schedule.completionStatus != .skipped {
                    QuickActionButton(
                        icon: "forward.fill",
                        label: "Skip",
                        color: Color.theme.textSecondary,
                        action: onSkip
                    )
                }
            }
        }
        .cardStyle()
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
    }
}
