import SwiftUI

struct HeatmapView: View {
    let data: [Date: Double] // date -> completion rate (0-1)
    let weeks: Int
    
    init(data: [Date: Double] = [:], weeks: Int = 12) {
        self.data = data
        self.weeks = weeks
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Heatmap")
                .font(.headline)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(0..<weeks, id: \.self) { week in
                        VStack(spacing: 3) {
                            ForEach(0..<7, id: \.self) { day in
                                let date = Date().adding(days: -(weeks - 1 - week) * 7 + day - 6)
                                let value = data[date.startOfDay] ?? 0
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(colorForValue(value))
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: 4) {
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForValue(value))
                        .frame(width: 12, height: 12)
                }
                
                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }
    
    private func colorForValue(_ value: Double) -> Color {
        if value == 0 {
            return Color(.systemGray5)
        }
        return Color.theme.success.opacity(0.2 + value * 0.8)
    }
}
