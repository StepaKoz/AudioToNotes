import AVFoundation
import Combine

final class FilePickerViewModel: ObservableObject {
    @Published var audioFile: AudioFile?
    @Published var detectedNotes: [Note] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0.0
    
    private var analyzer: AudioAnalyzer?
    
    func loadAudioFile(from url: URL) {
        isLoading = true
        errorMessage = nil
        detectedNotes = []
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                guard url.startAccessingSecurityScopedResource() else {
                    throw AudioError.fileAccessDenied
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                let file = try AudioFile(url: url)
                self.analyzer = AudioAnalyzer(sampleRate: file.sampleRate)
                
                DispatchQueue.main.async {
                    self.audioFile = file
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    func analyzeAudio() {
        guard let audioFile = audioFile, let analyzer = analyzer else { return }
        
        isAnalyzing = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let notes = try analyzer.analyze(audioFile: audioFile)
                
                DispatchQueue.main.async {
                    self.detectedNotes = notes
                    self.isAnalyzing = false
                    print("Найдено нот:", notes.count)
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        isLoading = false
        isAnalyzing = false
        
        if let audioError = error as? AudioError {
            errorMessage = audioError.localizedDescription
        } else {
            errorMessage = "Ошибка: \(error.localizedDescription)"
        }
        
        print("Ошибка:", error)
    }
}
