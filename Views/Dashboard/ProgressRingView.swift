import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let completed: Int
    let total: Int
    let freeMinutes: Int
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        HStack(spacing: 24) {
            // Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.theme.textSecondary.opacity(0.15), lineWidth: 10)
                    .frame(width: 100, height: 100)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        AngularGradient(
                            colors: [Color.theme.primary, Color.theme.accent, Color.theme.primary],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                // Percentage text
                VStack(spacing: 2) {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("done")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stats
            VStack(alignment: .leading, spacing: 12) {
                StatRow(
                    icon: "checkmark.circle.fill",
                    label: "Completed",
                    value: "\(completed)/\(total)",
                    color: Color.theme.success
                )
                
                StatRow(
                    icon: "clock.fill",
                    label: "Free Time",
                    value: Date.formatDuration(minutes: freeMinutes),
                    color: Color.theme.primary
                )
                
                StatRow(
                    icon: "flame.fill",
                    label: "Streak",
                    value: "Active",
                    color: Color.theme.accent
                )
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 20)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}
