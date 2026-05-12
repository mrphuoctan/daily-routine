import Foundation
import MediaPlayer

class MediaControlService: ObservableObject {
    static let shared = MediaControlService()
    
    @Published var isPlaying: Bool = false
    @Published var currentTitle: String = ""
    @Published var currentArtist: String = ""
    @Published var currentAlbumArt: Data?
    @Published var currentMode: FocusMode = .none
    @Published var isVisible: Bool = false
    
    private var timer: Timer?
    
    private init() {
        updateNowPlaying()
        // Poll for now playing updates
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.updateNowPlaying()
        }
    }
    
    // MARK: - Focus Modes
    enum FocusMode: String, CaseIterable {
        case none = "None"
        case study = "Study"
        case deepWork = "Deep Work"
        case gym = "Gym"
        case relax = "Relax"
        
        var icon: String {
            switch self {
            case .none: return "speaker.slash"
            case .study: return "book.fill"
            case .deepWork: return "brain.head.profile"
            case .gym: return "figure.run"
            case .relax: return "leaf.fill"
            }
        }
        
        var description: String {
            switch self {
            case .none: return "No focus music"
            case .study: return "Lo-fi, ambient study music"
            case .deepWork: return "Minimal, concentration-enhancing"
            case .gym: return "High energy, workout beats"
            case .relax: return "Calm, nature sounds"
            }
        }
    }
    
    // MARK: - Controls
    func play() {
        MPMusicPlayerController.systemMusicPlayer.play()
        isPlaying = true
        isVisible = true
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
    
    func dismiss() {
        isVisible = false
    }
    
    func show() {
        isVisible = true
    }
    
    // MARK: - Activity-based Music Mode
    func setModeForActivity(_ activity: ActivityType) {
        switch activity {
        case .hsk, .masterDegree, .ncpGenAI, .em:
            currentMode = .study
        case .work, .freelancer:
            currentMode = .deepWork
        case .gym:
            currentMode = .gym
        case .consoleRelax, .freeTime, .freeSocial:
            currentMode = .relax
        default:
            currentMode = .none
        }
    }
    
    func setMode(_ mode: FocusMode) {
        currentMode = mode
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
            if !isVisible && !currentTitle.isEmpty {
                isVisible = true
            }
        } else {
            currentTitle = ""
            currentArtist = ""
            currentAlbumArt = nil
        }
    }
}
