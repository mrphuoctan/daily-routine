import SwiftUI

struct MiniPlayerView: View {
    @StateObject private var mediaService = MediaControlService.shared
    @State private var showModeSelector = false
    
    var body: some View {
        VStack(spacing: 0) {
            if mediaService.isVisible {
                VStack(spacing: 0) {
                    // Main player bar
                    HStack(spacing: 12) {
                        // Album Art / Mode icon
                        if let artData = mediaService.currentAlbumArt,
                           let uiImage = UIImage(data: artData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(modeColor.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: mediaService.currentMode.icon)
                                        .foregroundStyle(modeColor)
                                )
                        }
                        
                        // Title & Artist / Mode
                        VStack(alignment: .leading, spacing: 2) {
                            if !mediaService.currentTitle.isEmpty {
                                Text(mediaService.currentTitle)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                
                                Text(mediaService.currentArtist)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            } else {
                                Text(mediaService.currentMode == .none ? "Music" : mediaService.currentMode.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                
                                Text(mediaService.currentMode.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        // Controls
                        HStack(spacing: 14) {
                            Button { mediaService.previous() } label: {
                                Image(systemName: "backward.fill")
                                    .font(.caption)
                            }
                            
                            Button { mediaService.togglePlayPause() } label: {
                                Image(systemName: mediaService.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.subheadline)
                                    .frame(width: 28, height: 28)
                                    .background(modeColor.opacity(0.15))
                                    .clipShape(Circle())
                            }
                            
                            Button { mediaService.next() } label: {
                                Image(systemName: "forward.fill")
                                    .font(.caption)
                            }
                            
                            // Mode picker
                            Button { showModeSelector.toggle() } label: {
                                Image(systemName: "music.note.list")
                                    .font(.caption)
                                    .foregroundStyle(modeColor)
                            }
                            
                            // Dismiss
                            Button { mediaService.dismiss() } label: {
                                Image(systemName: "xmark")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    
                    // Focus Mode selector (expandable)
                    if showModeSelector {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(MediaControlService.FocusMode.allCases, id: \.self) { mode in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            mediaService.setMode(mode)
                                            showModeSelector = false
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: mode.icon)
                                                .font(.caption2)
                                            Text(mode.rawValue)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(mediaService.currentMode == mode ? modeColor.opacity(0.2) : Color(.systemGray6))
                                        .foregroundStyle(mediaService.currentMode == mode ? modeColor : .secondary)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 8, y: -2)
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35), value: mediaService.isVisible)
    }
    
    private var modeColor: Color {
        switch mediaService.currentMode {
        case .none: return Color.theme.primary
        case .study: return Color(hex: "AF52DE")
        case .deepWork: return Color(hex: "007AFF")
        case .gym: return Color(hex: "34C759")
        case .relax: return Color(hex: "30B0C7")
        }
    }
}
