import SwiftUI
import Speech

struct VoiceCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isListening = false
    @State private var recognizedText = ""
    @State private var matchedActivity: ActivityType?
    @State private var authStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    let onCheckIn: (ActivityType) -> Void
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Microphone animation
                ZStack {
                    Circle()
                        .fill(isListening ? Color.theme.primary.opacity(0.1) : Color(.systemGray6))
                        .frame(width: 160, height: 160)
                        .scaleEffect(isListening ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isListening)
                    
                    Circle()
                        .fill(isListening ? Color.theme.primary.opacity(0.2) : Color(.systemGray5))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .font(.system(size: 40))
                        .foregroundStyle(isListening ? Color.theme.primary : .secondary)
                }
                
                // Status text
                VStack(spacing: 8) {
                    Text(isListening ? "Listening..." : "Tap to speak")
                        .font(.headline)
                    
                    if !recognizedText.isEmpty {
                        Text("\"\(recognizedText)\"")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }
                
                // Matched activity
                if let activity = matchedActivity {
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: activity.icon)
                                .foregroundStyle(activity.color)
                            Text(activity.rawValue)
                                .font(.title3).fontWeight(.bold)
                        }
                        
                        Button {
                            onCheckIn(activity)
                            dismiss()
                        } label: {
                            Text("Check In to \(activity.rawValue)")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(activity.color)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
                        }
                        .padding(.horizontal, 40)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Quick activity buttons
                VStack(spacing: 8) {
                    Text("Or tap to select:")
                        .font(.caption).foregroundStyle(.tertiary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ActivityType.allCases.prefix(8), id: \.self) { type in
                                Button {
                                    matchedActivity = type
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: type.icon)
                                            .font(.caption)
                                        Text(type.rawValue)
                                            .font(.system(size: 9))
                                    }
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .foregroundStyle(.primary)
                                }
                            }
                        }
                        .padding(.horizontal, AppConstants.screenPadding)
                    }
                }
            }
            .padding(.bottom, 20)
            .navigationTitle("Voice Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onTapGesture {
                if !isListening { startListening() }
                else { stopListening() }
            }
            .onAppear { requestSpeechAuth() }
        }
    }
    
    private func requestSpeechAuth() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async { authStatus = status }
        }
    }
    
    private func startListening() {
        guard authStatus == .authorized, let recognizer = speechRecognizer, recognizer.isAvailable else { return }
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        isListening = true
        
        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                recognizedText = result.bestTranscription.formattedString
                matchActivity(from: recognizedText)
            }
            if error != nil || (result?.isFinal ?? false) {
                stopListening()
            }
        }
        
        // Auto-stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if isListening { stopListening() }
        }
    }
    
    private func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
    
    private func matchActivity(from text: String) {
        let lower = text.lowercased()
        for type in ActivityType.allCases {
            if lower.contains(type.rawValue.lowercased()) ||
               lower.contains(type.rawValue.lowercased().replacingOccurrences(of: " / ", with: " ")) {
                withAnimation { matchedActivity = type }
                return
            }
        }
        // Fuzzy matching
        let keywords: [(String, ActivityType)] = [
            ("work", .work), ("office", .work),
            ("gym", .gym), ("run", .gym), ("exercise", .gym),
            ("study", .hsk), ("chinese", .hsk), ("language", .hsk),
            ("master", .masterDegree), ("school", .masterDegree),
            ("freelance", .freelancer), ("code", .freelancer),
            ("sleep", .sleep), ("rest", .consoleRelax),
            ("eat", .dinner), ("lunch", .lunchRest), ("dinner", .dinner),
        ]
        for (keyword, type) in keywords {
            if lower.contains(keyword) {
                withAnimation { matchedActivity = type }
                return
            }
        }
    }
}
