import SwiftUI

struct MiniPlayerView: View {
    @StateObject private var mediaService = MediaControlService.shared
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !mediaService.currentTitle.isEmpty {
                HStack(spacing: 12) {
                    // Album Art
                    if let artData = mediaService.currentAlbumArt,
                       let uiImage = UIImage(data: artData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.theme.primary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundStyle(Color.theme.primary)
                            )
                    }
                    
                    // Title & Artist
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mediaService.currentTitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text(mediaService.currentArtist)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 16) {
                        Button { mediaService.previous() } label: {
                            Image(systemName: "backward.fill")
                                .font(.caption)
                        }
                        
                        Button { mediaService.togglePlayPause() } label: {
                            Image(systemName: mediaService.isPlaying ? "pause.fill" : "play.fill")
                                .font(.subheadline)
                        }
                        
                        Button { mediaService.next() } label: {
                            Image(systemName: "forward.fill")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
            }
        }
    }
}
