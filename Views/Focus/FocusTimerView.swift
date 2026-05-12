import SwiftUI

struct FocusTimerView: View {
    @State private var selectedMode: MediaControlService.FocusMode = .deepWork
    @State private var timerMinutes: Int = 25
    @State private var remainingSeconds: Int = 25 * 60
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var sessionsCompleted: Int = 0
    @State private var isBreak: Bool = false
    
    let breakMinutes = 5
    let longBreakMinutes = 15
    let longBreakAfter = 4
    
    var body: some View {
        VStack(spacing: 32) {
            // Mode selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MediaControlService.FocusMode.allCases.filter { $0 != .none }, id: \.self) { mode in
                        Button {
                            if !isRunning { selectedMode = mode; resetTimer() }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: mode.icon)
                                Text(mode.rawValue)
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedMode == mode ? modeColor.opacity(0.2) : Color(.systemGray6))
                            .foregroundStyle(selectedMode == mode ? modeColor : .secondary)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, AppConstants.screenPadding)
            }
            
            Spacer()
            
            // Timer ring
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 240, height: 240)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(isBreak ? Color.theme.success : modeColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                VStack(spacing: 8) {
                    Text(isBreak ? "Break" : selectedMode.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text(timeString)
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                    
                    Text("Session \(sessionsCompleted + 1)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Duration presets
            if !isRunning {
                HStack(spacing: 12) {
                    ForEach([15, 25, 45, 60], id: \.self) { mins in
                        Button {
                            timerMinutes = mins
                            resetTimer()
                        } label: {
                            Text("\(mins)m")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(timerMinutes == mins ? modeColor.opacity(0.15) : Color(.systemGray6))
                                .foregroundStyle(timerMinutes == mins ? modeColor : .secondary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 32) {
                Button { resetTimer() } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 56, height: 56)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Button { toggleTimer() } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(modeColor)
                        .clipShape(Circle())
                        .shadow(color: modeColor.opacity(0.3), radius: 8, y: 4)
                }
                
                Button {
                    isRunning = false
                    timer?.invalidate()
                    sessionsCompleted += 1
                    startBreak()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .frame(width: 56, height: 56)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            
            // Sessions completed
            HStack(spacing: 8) {
                ForEach(0..<longBreakAfter, id: \.self) { i in
                    Circle()
                        .fill(i < sessionsCompleted % longBreakAfter ? modeColor : Color(.systemGray5))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Focus Timer")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { timer?.invalidate() }
    }
    
    private var progress: Double {
        let total = isBreak ? Double((sessionsCompleted % longBreakAfter == 0 ? longBreakMinutes : breakMinutes) * 60) : Double(timerMinutes * 60)
        guard total > 0 else { return 0 }
        return Double(remainingSeconds) / total
    }
    
    private var timeString: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private var modeColor: Color {
        switch selectedMode {
        case .none: return Color.theme.primary
        case .study: return Color(hex: "AF52DE")
        case .deepWork: return Color(hex: "007AFF")
        case .gym: return Color(hex: "34C759")
        case .relax: return Color(hex: "30B0C7")
        }
    }
    
    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            isRunning = false
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    timer?.invalidate()
                    isRunning = false
                    if isBreak {
                        isBreak = false
                        resetTimer()
                    } else {
                        sessionsCompleted += 1
                        startBreak()
                    }
                }
            }
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        isRunning = false
        isBreak = false
        remainingSeconds = timerMinutes * 60
    }
    
    private func startBreak() {
        isBreak = true
        let breakDuration = sessionsCompleted % longBreakAfter == 0 ? longBreakMinutes : breakMinutes
        remainingSeconds = breakDuration * 60
    }
}
