import SwiftUI
import SwiftData

struct AIInsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var aiService = AIScheduleService.shared
    @State private var suggestions: [ScheduleSuggestion] = []
    @State private var recoverySuggestions: [String] = []
    @State private var burnoutPrediction: BurnoutPrediction?
    @State private var isAnalyzing = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isAnalyzing {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Analyzing your patterns...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    // Fatigue Card
                    fatigueCard
                    
                    // Burnout Prediction
                    if let prediction = burnoutPrediction {
                        burnoutCard(prediction)
                    }
                    
                    // Recovery Suggestions
                    if !recoverySuggestions.isEmpty {
                        recoverySection
                    }
                    
                    // AI Suggestions
                    if !suggestions.isEmpty {
                        suggestionsSection
                    }
                    
                    if suggestions.isEmpty && aiService.fatigueLevel == .normal {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.theme.success)
                            Text("All Good!")
                                .font(.headline)
                            Text("No issues detected. Keep up the great work!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("AI Insights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { analyzeData() } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear { analyzeData() }
    }
    
    private var fatigueCard: some View {
        HStack(spacing: 16) {
            Text(aiService.fatigueLevel.emoji)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Fatigue Level")
                    .font(.caption).foregroundStyle(.secondary)
                Text(aiService.fatigueLevel.rawValue)
                    .font(.title3).fontWeight(.bold)
            }
            
            Spacer()
            
            Image(systemName: fatigueIcon)
                .font(.title2)
                .foregroundStyle(fatigueColor)
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private func burnoutCard(_ prediction: BurnoutPrediction) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Burnout Prediction")
                    .font(.headline).fontWeight(.bold)
                Spacer()
                Text(prediction.riskLevel)
                    .font(.caption).fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: prediction.riskScore > 0.5 ? "FF453A" : "34C759").opacity(0.15))
                    .foregroundStyle(Color(hex: prediction.riskScore > 0.5 ? "FF453A" : "34C759"))
                    .clipShape(Capsule())
            }
            
            // Risk bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: prediction.riskScore > 0.5 ? "FF453A" : prediction.riskScore > 0.3 ? "FF9500" : "34C759"))
                        .frame(width: geo.size.width * prediction.riskScore, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("Estimated \(prediction.estimatedDaysUntilBurnout) days at current pace")
                .font(.caption).foregroundStyle(.secondary)
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private var recoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recovery Suggestions")
                .font(.headline).fontWeight(.bold)
            
            ForEach(recoverySuggestions, id: \.self) { suggestion in
                HStack(alignment: .top, spacing: 8) {
                    Text(String(suggestion.prefix(2)))
                    Text(String(suggestion.dropFirst(2)))
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Schedule Suggestions")
                .font(.headline).fontWeight(.bold)
            
            ForEach(suggestions) { suggestion in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: suggestion.type.icon)
                        .foregroundStyle(Color(hex: suggestion.priority.color))
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(suggestion.title)
                            .font(.subheadline).fontWeight(.medium)
                        Text(suggestion.description)
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private var fatigueIcon: String {
        switch aiService.fatigueLevel {
        case .normal: return "battery.100.bolt"
        case .moderate: return "battery.75"
        case .high: return "battery.25"
        case .severe: return "battery.0"
        }
    }
    
    private var fatigueColor: Color {
        switch aiService.fatigueLevel {
        case .normal: return Color.theme.success
        case .moderate: return Color.theme.warning
        case .high: return Color(hex: "FF9500")
        case .severe: return Color.theme.error
        }
    }
    
    private func analyzeData() {
        isAnalyzing = true
        
        let schedules = (try? modelContext.fetch(FetchDescriptor<DailySchedule>())) ?? []
        let logs = (try? modelContext.fetch(FetchDescriptor<ActivityLog>())) ?? []
        let templates = (try? modelContext.fetch(FetchDescriptor<ScheduleTemplate>())) ?? []
        
        // Run AI analyses
        var allSuggestions: [ScheduleSuggestion] = []
        allSuggestions.append(contentsOf: aiService.optimizeSchedule(schedules: schedules, historicalLogs: logs))
        allSuggestions.append(contentsOf: aiService.getProductivityRecommendations(logs: logs))
        allSuggestions.append(contentsOf: aiService.distributeTasksEvenly(templates: templates))
        allSuggestions.append(contentsOf: aiService.generateAdaptiveSchedule(historicalLogs: logs, currentTemplates: templates))
        
        suggestions = allSuggestions.sorted { $0.priority > $1.priority }
        
        // Fatigue
        let _ = aiService.detectFatigue(recentLogs: logs, sleepHours: 7)
        recoverySuggestions = aiService.getRecoverySuggestions(fatigue: aiService.fatigueLevel)
        
        // Burnout prediction
        burnoutPrediction = aiService.predictBurnout(weeklyWorkHours: 45, sleepConsistency: 75, completionTrend: [0.8, 0.75, 0.7])
        
        isAnalyzing = false
    }
}
