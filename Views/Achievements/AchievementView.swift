import SwiftUI
import SwiftData

struct AchievementView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var achievements: [Achievement] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats
                HStack(spacing: 16) {
                    StatBadge(value: "\(unlockedCount)", label: "Unlocked", icon: "trophy.fill", color: Color(hex: "FFD700"))
                    StatBadge(value: "\(achievements.count)", label: "Total", icon: "star.fill", color: Color.theme.primary)
                    StatBadge(value: "\(Int(overallProgress * 100))%", label: "Progress", icon: "chart.bar.fill", color: Color.theme.success)
                }
                .padding(.horizontal, AppConstants.screenPadding)
                
                // Categories
                let categories = Dictionary(grouping: achievements) { $0.category }
                ForEach(["general", "streak", "time", "activity", "tracking"], id: \.self) { cat in
                    if let items = categories[cat] {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(cat.capitalized)
                                .font(.headline).fontWeight(.bold)
                            
                            ForEach(items, id: \.id) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, AppConstants.screenPadding)
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadOrSeedAchievements() }
    }
    
    private var unlockedCount: Int { achievements.filter { $0.isUnlocked }.count }
    private var overallProgress: Double {
        guard !achievements.isEmpty else { return 0 }
        return achievements.map { $0.progress }.reduce(0, +) / Double(achievements.count)
    }
    
    private func loadOrSeedAchievements() {
        let existing = (try? modelContext.fetch(FetchDescriptor<Achievement>())) ?? []
        if existing.isEmpty {
            // Seed achievements
            for def in AchievementDefinition.allCases {
                let a = Achievement(title: def.title, description: def.description, icon: def.icon, category: def.category, requirement: def.requirement)
                modelContext.insert(a)
            }
            try? modelContext.save()
            achievements = (try? modelContext.fetch(FetchDescriptor<Achievement>())) ?? []
        } else {
            achievements = existing
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color(hex: "FFD700").opacity(0.2) : Color(.systemGray5))
                    .frame(width: 48, height: 48)
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundStyle(achievement.isUnlocked ? Color(hex: "FFD700") : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.title)
                        .font(.subheadline).fontWeight(.semibold)
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.theme.success)
                    }
                }
                Text(achievement.achievementDescription)
                    .font(.caption).foregroundStyle(.secondary)
                
                // Progress bar
                if !achievement.isUnlocked {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray5))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.theme.primary)
                                .frame(width: geo.size.width * achievement.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
            
            Spacer()
            
            Text("\(Int(achievement.progress * 100))%")
                .font(.caption2).fontWeight(.bold)
                .foregroundStyle(achievement.isUnlocked ? Color(hex: "FFD700") : .secondary)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.title3).fontWeight(.bold)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
    }
}
