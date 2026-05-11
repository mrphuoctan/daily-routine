import Foundation
import MediaPlayer

class MediaControlService: ObservableObject {
    static let shared = MediaControlService()
    
    @Published var isPlaying: Bool = false
    @Published var currentTitle: String = ""
    @Published var currentArtist: String = ""
    @Published var currentAlbumArt: Data?
    
    private init() {
        updateNowPlaying()
    }
    
    // MARK: - Controls
    func play() {
        MPMusicPlayerController.systemMusicPlayer.play()
        isPlaying = true
        updateNowPlaying()
    }
    
    func pause() {
        MPMusicPlayerController.systemMusicPlayer.pause()
        isPlaying = false
    }
    
    func next() {
        MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
        updateNowPlaying()
    }
    
    func previous() {
        MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
        updateNowPlaying()
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    // MARK: - Now Playing Info
    func updateNowPlaying() {
        if let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem {
            currentTitle = nowPlaying.title ?? "Unknown"
            currentArtist = nowPlaying.artist ?? "Unknown"
            if let artwork = nowPlaying.artwork {
                let image = artwork.image(at: CGSize(width: 60, height: 60))
                currentAlbumArt = image?.pngData()
            }
        } else {
            currentTitle = ""
            currentArtist = ""
            currentAlbumArt = nil
        }
    }
}
