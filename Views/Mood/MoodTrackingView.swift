import SwiftUI
import SwiftData

struct MoodTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var entries: [MoodEntry] = []
    @State private var showAddEntry = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's mood
                todayMoodCard
                
                // Weekly trend
                weeklyTrend
                
                // History
                moodHistory
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mood Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddEntry = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAddEntry) {
            MoodEntrySheet { entry in
                modelContext.insert(entry)
                try? modelContext.save()
                loadEntries()
            }
        }
        .onAppear { loadEntries() }
    }
    
    private var todayMoodCard: some View {
        VStack(spacing: 12) {
            if let today = entries.first(where: { Calendar.current.isDateInToday($0.date) }) {
                Text(today.moodEmoji).font(.system(size: 48))
                Text("Today's Mood").font(.headline)
                HStack(spacing: 24) {
                    VStack { Text("Mood"); Text("\(today.moodLevel)/5").fontWeight(.bold) }
                    VStack { Text("Energy"); Text("\(today.energyLevel)/5").fontWeight(.bold) }
                    VStack { Text("Stress"); Text("\(today.stressLevel)/5").fontWeight(.bold) }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
                Text("😐").font(.system(size: 48))
                Text("No mood logged today").font(.subheadline).foregroundStyle(.secondary)
                Button("Log Now") { showAddEntry = true }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.theme.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private var weeklyTrend: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Trend").font(.headline).fontWeight(.bold)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - dayOffset), to: Date())!
                    let entry = entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                    
                    VStack(spacing: 4) {
                        if let e = entry {
                            Text(e.moodEmoji).font(.title3)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(moodColor(e.moodLevel))
                                .frame(height: CGFloat(e.moodLevel) * 12)
                        } else {
                            Text("—").font(.caption).foregroundStyle(.tertiary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 12)
                        }
                        Text(date, format: .dateTime.weekday(.abbreviated))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private var moodHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History").font(.headline).fontWeight(.bold)
            
            ForEach(entries.prefix(20), id: \.id) { entry in
                HStack(spacing: 12) {
                    Text(entry.moodEmoji).font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.date, format: .dateTime.month(.abbreviated).day().weekday(.abbreviated))
                            .font(.subheadline).fontWeight(.medium)
                        if !entry.note.isEmpty {
                            Text(entry.note).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        MoodPill(emoji: "😊", value: entry.moodLevel)
                        MoodPill(emoji: "⚡", value: entry.energyLevel)
                        MoodPill(emoji: "😰", value: entry.stressLevel)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .cardStyle()
        .padding(.horizontal, AppConstants.screenPadding)
    }
    
    private func moodColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.theme.error
        case 2: return Color.theme.warning
        case 3: return Color.theme.textSecondary
        case 4: return Color.theme.primary
        case 5: return Color.theme.success
        default: return .secondary
        }
    }
    
    private func loadEntries() {
        entries = (try? modelContext.fetch(FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)]))) ?? []
    }
}

struct MoodPill: View {
    let emoji: String
    let value: Int
    var body: some View {
        Text("\(emoji)\(value)")
            .font(.system(size: 10))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
}

struct MoodEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (MoodEntry) -> Void
    @State private var mood = 3
    @State private var energy = 3
    @State private var stress = 3
    @State private var note = ""
    
    let emojis = ["😢", "😔", "😐", "😊", "😁"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(emojis[mood - 1]).font(.system(size: 64))
                
                VStack(spacing: 16) {
                    MoodSlider(label: "Mood", value: $mood, color: Color.theme.primary)
                    MoodSlider(label: "Energy", value: $energy, color: Color.theme.success)
                    MoodSlider(label: "Stress", value: $stress, color: Color.theme.error)
                }
                .padding(.horizontal, 24)
                
                TextField("How are you feeling? (optional)", text: $note, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.top, 30)
            .navigationTitle("Log Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = MoodEntry(moodLevel: mood, energyLevel: energy, stressLevel: stress, note: note)
                        onSave(entry)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MoodSlider: View {
    let label: String
    @Binding var value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label).font(.subheadline).fontWeight(.medium)
                Spacer()
                Text("\(value)/5").font(.caption).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.25)) { value = i }
                    } label: {
                        Circle()
                            .fill(i <= value ? color : Color(.systemGray5))
                            .frame(width: 36, height: 36)
                            .overlay(Text("\(i)").font(.caption2).fontWeight(.bold).foregroundStyle(i <= value ? .white : .secondary))
                    }
                }
            }
        }
    }
}
