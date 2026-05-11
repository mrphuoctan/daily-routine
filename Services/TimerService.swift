import Foundation
import Combine

class TimerService: ObservableObject {
    static let shared = TimerService()
    
    @Published var activeActivityType: ActivityType?
    @Published var elapsedSeconds: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedElapsed: TimeInterval = 0
    
    private init() {}
    
    // MARK: - Timer Controls
    func start(activity: ActivityType) {
        activeActivityType = activity
        isRunning = true
        isPaused = false
        startTime = Date()
        pausedElapsed = 0
        elapsedSeconds = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.elapsedSeconds = self.pausedElapsed + Date().timeIntervalSince(start)
        }
    }
    
    func pause() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        pausedElapsed = elapsedSeconds
        timer?.invalidate()
        timer = nil
        startTime = nil
    }
    
    func resume() {
        guard isPaused else { return }
        isPaused = false
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.elapsedSeconds = self.pausedElapsed + Date().timeIntervalSince(start)
        }
    }
    
    func stop() -> TimeInterval {
        let total = elapsedSeconds
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        activeActivityType = nil
        elapsedSeconds = 0
        startTime = nil
        pausedElapsed = 0
        return total
    }
    
    // MARK: - Formatted Time
    var formattedTime: String {
        Date.formatTimerDuration(seconds: elapsedSeconds)
    }
    
    var formattedTimeShort: String {
        Date.formatDuration(seconds: elapsedSeconds)
    }
}
