import SwiftUI
import SwiftData

struct EvidenceGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var photos: [EvidencePhoto] = []
    @State private var selectedPhoto: EvidencePhoto?
    
    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Stats header
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(photos.count)")
                            .font(.title2).fontWeight(.bold)
                        Text("Photos")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(uniqueActivities)")
                            .font(.title2).fontWeight(.bold)
                        Text("Activities")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(uniqueDays)")
                            .font(.title2).fontWeight(.bold)
                        Text("Days")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
                .padding(.horizontal, AppConstants.screenPadding)
                
                // Photo Grid
                if photos.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundStyle(.tertiary)
                        Text("No evidence photos yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Take photos during activities\nto track your proof of work")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    // Group by date
                    let grouped = groupedPhotos
                    
                    ForEach(Array(grouped.keys.sorted().reversed()), id: \.self) { dateKey in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dateKey)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, AppConstants.screenPadding)
                            
                            LazyVGrid(columns: columns, spacing: 4) {
                                ForEach(grouped[dateKey] ?? [], id: \.id) { photo in
                                    Button {
                                        selectedPhoto = photo
                                    } label: {
                                        photoThumbnail(photo)
                                    }
                                }
                            }
                            .padding(.horizontal, AppConstants.screenPadding)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Evidence Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedPhoto) { photo in
            EvidenceDetailSheet(photo: photo) {
                modelContext.delete(photo)
                try? modelContext.save()
                loadPhotos()
            }
        }
        .onAppear { loadPhotos() }
    }
    
    private func photoThumbnail(_ photo: EvidencePhoto) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let data = photo.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.tertiary)
                    )
            }
            
            // Activity badge
            if let log = photo.activityLog {
                Text(log.activity.rawValue)
                    .font(.system(size: 8))
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(4)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private var groupedPhotos: [String: [EvidencePhoto]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        
        var result: [String: [EvidencePhoto]] = [:]
        for photo in photos {
            let key = formatter.string(from: photo.capturedAt)
            result[key, default: []].append(photo)
        }
        return result
    }
    
    private var uniqueActivities: Int {
        Set(photos.compactMap { $0.activityLog?.activityType }).count
    }
    
    private var uniqueDays: Int {
        Set(photos.map { Calendar.current.startOfDay(for: $0.capturedAt) }).count
    }
    
    private func loadPhotos() {
        let descriptor = FetchDescriptor<EvidencePhoto>(
            sortBy: [SortDescriptor(\.capturedAt, order: .reverse)]
        )
        photos = (try? modelContext.fetch(descriptor)) ?? []
    }
}

// MARK: - Detail Sheet
struct EvidenceDetailSheet: View {
    let photo: EvidencePhoto
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let data = photo.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if let log = photo.activityLog {
                            HStack(spacing: 8) {
                                Image(systemName: log.activity.icon)
                                    .foregroundStyle(log.activity.color)
                                Text(log.activity.rawValue)
                                    .font(.headline)
                            }
                        }
                        
                        if !photo.caption.isEmpty {
                            Text(photo.caption)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(photo.capturedAt, format: .dateTime.month().day().year().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        Label("Delete Photo", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .padding(.horizontal)
                }
                .padding(.top, 16)
            }
            .navigationTitle("Evidence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
