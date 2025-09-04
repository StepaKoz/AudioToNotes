import Foundation

struct Note: Identifiable, Hashable {
    let id = UUID()
    let pitch: String
    let octave: Int
    let frequency: Double
    var startTime: Double
    var duration: Double
    let confidence: Double
    
    public static let validPitches = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private static let minFrequency = 20.0
    private static let maxFrequency = 20000.0
    
    var midiNumber: Int {
        Note.frequencyToSemitone(frequency)
    }
    
    var fullName: String {
        "\(pitch)\(octave)"
    }
    
    init(pitch: String, octave: Int, frequency: Double,
         startTime: Double, duration: Double, confidence: Double = 1.0) throws {
        
        guard Note.validPitches.contains(pitch) else {
            throw AudioError.invalidPitch(pitch: pitch)
        }
        
        guard (Note.minFrequency...Note.maxFrequency).contains(frequency) else {
            throw AudioError.frequencyOutOfRange(
                min: Note.minFrequency,
                max: Note.maxFrequency,
                actual: frequency
            )
        }
        
        self.pitch = pitch
        self.octave = octave
        self.frequency = frequency
        self.startTime = startTime
        self.duration = duration
        self.confidence = min(max(confidence, 0), 1)
    }
    
    static func fromFrequency(_ freq: Double, confidence: Double = 1.0) throws -> Note {
        let semitone = 12 * log2(freq / 440.0) + 69
        let index = (Int(round(semitone)) % 12 + 12) % 12
        let octave = Int(round(semitone / 12)) - 1
        
        do {
            return try Note(
                pitch: validPitches[index],
                octave: octave,
                frequency: freq,
                startTime: 0,
                duration: 0,
                confidence: confidence
            )
        } catch {
            throw AudioError.noteCreationFailed(
                reason: "Не удалось создать ноту для частоты \(freq) Гц: \(error.localizedDescription)"
            )
        }
    }
    
    private static func frequencyToSemitone(_ freq: Double) -> Int {
        Int(12 * log2(freq / 440.0)) + 69
    }
}

extension Note {
    static let A4 = try! Note(pitch: "A", octave: 4, frequency: 440.0,
                             startTime: 0, duration: 1, confidence: 1.0)
}
