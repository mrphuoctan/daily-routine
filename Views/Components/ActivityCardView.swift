import SwiftUI

struct ActivityCardView: View {
    let activity: ActivityType
    let timeRange: String
    let duration: String
    let status: CompletionStatus
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Color bar
            RoundedRectangle(cornerRadius: 3)
                .fill(activity.color)
                .frame(width: 4, height: isCompact ? 36 : 48)
            
            // Icon
            Image(systemName: activity.icon)
                .font(isCompact ? .caption : .subheadline)
                .foregroundStyle(activity.color)
                .frame(width: isCompact ? 28 : 36, height: isCompact ? 28 : 36)
                .background(activity.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: isCompact ? 8 : 10))
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.rawValue)
                    .font(isCompact ? .caption : .subheadline)
                    .fontWeight(.semibold)
                
                Text(timeRange)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Duration & Status
            VStack(alignment: .trailing, spacing: 4) {
                Text(duration)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Circle()
                    .fill(status.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}
