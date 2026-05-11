import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerService: TimerService
    
    var body: some View {
        if timerService.isRunning, let activity = timerService.activeActivityType {
            HStack(spacing: 10) {
                // Pulsing dot
                Circle()
                    .fill(activity.color)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(activity.color.opacity(0.4), lineWidth: 2)
                            .scaleEffect(timerService.isPaused ? 1.0 : 1.8)
                            .opacity(timerService.isPaused ? 1.0 : 0)
                            .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: timerService.isPaused)
                    )
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(activity.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text(timerService.formattedTime)
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(activity.color)
                }
                
                if timerService.isPaused {
                    Text("PAUSED")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.theme.warning)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.theme.warning.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(activity.color.opacity(0.08))
            .clipShape(Capsule())
        }
    }
}
