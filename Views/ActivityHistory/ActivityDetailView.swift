import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    let log: ActivityLog
    @Environment(\.modelContext) private var modelContext
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var evidencePhotos: [EvidencePhoto] = []
    
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
                
                // Evidence Photos Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Evidence Photos")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingCamera = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "camera.fill")
                                Text("Add")
                            }
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.theme.primary.opacity(0.12))
                            .foregroundStyle(Color.theme.primary)
                            .clipShape(Capsule())
                        }
                    }
                    
                    if log.evidencePhotos.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(.tertiary)
                            Text("No evidence photos")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Take a selfie or photo as proof")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(log.evidencePhotos, id: \.id) { photo in
                                    VStack(spacing: 6) {
                                        if let data = photo.imageData, let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        
                                        Text(photo.capturedAt.timeString())
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        
                                        if !photo.caption.isEmpty {
                                            Text(photo.caption)
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                                .lineLimit(1)
                                        }
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            modelContext.delete(photo)
                                            try? modelContext.save()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
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
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $capturedImage)
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                saveEvidence(image: image)
            }
        }
    }
    
    private func saveEvidence(image: UIImage) {
        let photo = EvidencePhoto(
            imageData: image.jpegData(compressionQuality: 0.7),
            caption: "\(log.activity.rawValue) - \(Date().timeString())",
            activityLog: log
        )
        modelContext.insert(photo)
        log.evidencePhotos.append(photo)
        try? modelContext.save()
        capturedImage = nil
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
