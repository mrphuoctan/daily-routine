import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    let log: ActivityLog
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 12) {
                    Image(systemName: log.activity.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(log.activity.color)
                    
                    Text(log.activity.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(log.date.dateString())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(log.completionStatus.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(log.completionStatus.color.opacity(0.15))
                        .foregroundStyle(log.completionStatus.color)
                        .clipShape(Capsule())
                }
                .cardStyle()
                
                // Time Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time Details")
                        .font(.headline)
                    
                    DetailRow(label: "Planned", value: "\(log.plannedStartTime.timeString()) → \(log.plannedEndTime.timeString())")
                    DetailRow(label: "Planned Duration", value: Date.formatDuration(minutes: log.plannedDurationMinutes))
                    
                    if let start = log.actualStartTime {
                        DetailRow(label: "Actual Start", value: start.timeString())
                    }
                    if let end = log.actualEndTime {
                        DetailRow(label: "Actual End", value: end.timeString())
                    }
                    if let actual = log.actualDurationMinutes {
                        DetailRow(label: "Actual Duration", value: Date.formatDuration(minutes: actual))
                    }
                    if let diff = log.durationDifferenceMinutes {
                        DetailRow(
                            label: "Difference",
                            value: diff >= 0 ? "+\(diff)m" : "\(diff)m",
                            valueColor: diff >= 0 ? Color.theme.success : Color.theme.error
                        )
                    }
                }
                .cardStyle()
                
                // Notes
                if !log.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        Text(log.notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                }
            }
            .padding(.horizontal, AppConstants.screenPadding)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Activity Detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(valueColor)
        }
    }
}
