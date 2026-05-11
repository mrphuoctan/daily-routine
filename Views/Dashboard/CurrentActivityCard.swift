import SwiftUI

struct CurrentActivityCard: View {
    let schedule: DailySchedule
    var onCheckIn: () -> Void
    var onCheckOut: () -> Void
    
    @EnvironmentObject var timerService: TimerService
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Activity Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NOW")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(2)
                    
                    Text(schedule.activity.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Image(systemName: schedule.activity.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.8))
                    .scaleEffect(animate ? 1.1 : 1.0)
            }
            
            // Time Info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(schedule.timeRangeString)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text("\(schedule.plannedDurationMinutes)m planned")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Timer Display
                if timerService.isRunning && timerService.activeActivityType == schedule.activity {
                    Text(timerService.formattedTime)
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 6)
            
            // Action Button
            HStack(spacing: 12) {
                if schedule.completionStatus == .inProgress {
                    Button(action: onCheckOut) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Check Out")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(schedule.activity.color)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(Capsule())
                    }
                } else {
                    Button(action: onCheckIn) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Check In")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(schedule.activity.color)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [schedule.activity.color, schedule.activity.color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: schedule.activity.color.opacity(0.3), radius: 15, x: 0, y: 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                animate = true
            }
        }
    }
    
    private var progress: CGFloat {
        let now = Date()
        let start = schedule.plannedStartTime
        let end = schedule.plannedEndTime
        let total = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)
        return CGFloat(min(max(elapsed / total, 0), 1))
    }
}
