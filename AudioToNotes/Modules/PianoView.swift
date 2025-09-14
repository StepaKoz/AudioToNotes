import SwiftUI

struct PianoView: View {
    let detectedNotes: [Note]
    @State private var activeNotes: Set<String> = []
    @State private var currentTime: Double = 0
    @State private var animationTimer: Timer?
    @State private var isPlaying: Bool = false
    
    private let whiteKeys = ["C3", "D3", "E3", "F3", "G3", "A3", "B3",
                            "C4", "D4", "E4", "F4", "G4", "A4", "B4",
                            "C5", "D5", "E5", "F5", "G5", "A5", "B5"]
    
    private let blackKeysPositions: [(key: String, position: Int)] = [
        ("C#3", 0), ("D#3", 1),
        ("F#3", 3), ("G#3", 4), ("A#3", 5),
        ("C#4", 7), ("D#4", 8),
        ("F#4", 10), ("G#4", 11), ("A#4", 12),
        ("C#5", 14), ("D#5", 15),
        ("F#5", 17), ("G#5", 18), ("A#5", 19)
    ]
    
    private var maxTime: Double {
        detectedNotes.map { $0.startTime + $0.duration }.max() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Визуализация на клавишах")
                .font(.headline)
                .foregroundColor(ColorPalette.primary)
            
            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(Array(whiteKeys.enumerated()), id: \.element) { index, noteName in
                        PianoKeyView(
                            noteName: noteName,
                            isPressed: activeNotes.contains(noteName),
                            isBlackKey: false,
                            color: getColorForNote(noteName)
                        )
                    }
                }
                
                ForEach(blackKeysPositions, id: \.key) { blackKey in
                    PianoKeyView(
                        noteName: blackKey.key,
                        isPressed: activeNotes.contains(blackKey.key),
                        isBlackKey: true,
                        color: getColorForNote(blackKey.key)
                    )
                    .offset(x: CGFloat(blackKey.position) * 40.0 + 28.0)
                    .frame(height: 70)
                }
            }
            .frame(height: 140)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorPalette.secondary.opacity(0.7))
                    .shadow(color: ColorPalette.accent.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            
            HStack(spacing: 16) {
                Button(action: isPlaying ? stopAnimation : startAnimation) {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(isPlaying ? ColorPalette.accent : ColorPalette.primary)
                        .cornerRadius(8)
                }
                
                Text("Время: \(String(format: "%.1f", currentTime)) сек")
                    .font(.caption)
                    .foregroundColor(ColorPalette.primary)
                
                if isPlaying {
                    Text("Макс: \(String(format: "%.1f", maxTime)) сек")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
        .onAppear {
            stopAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
        .onChange(of: detectedNotes) { _ in
            stopAnimation()
        }
    }
    
    private func getColorForNote(_ noteName: String) -> Color {
        if let index = detectedNotes.firstIndex(where: { $0.fullName == noteName }) {
            return ColorPalette.noteColors[index % ColorPalette.noteColors.count]
        }
        return ColorPalette.primary
    }
    
    private func startAnimation() {
        stopAnimation()
        currentTime = 0
        activeNotes.removeAll()
        isPlaying = true
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            currentTime += 0.1
            
            if currentTime >= maxTime + 1.0 {
                stopAnimation()
                return
            }
            
            updateActiveNotes()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        activeNotes.removeAll()
        currentTime = 0
        isPlaying = false
    }
    
    private func updateActiveNotes() {
        var currentlyActiveNotes = Set<String>()
        
        for note in detectedNotes {
            let noteEndTime = note.startTime + note.duration
            if note.startTime <= currentTime && currentTime <= noteEndTime {
                currentlyActiveNotes.insert(note.fullName)
            }
        }
        
        withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
            activeNotes = currentlyActiveNotes
        }
    }
}
