import Foundation
import AVFoundation

enum AudioError: Error, LocalizedError {
    case fileAccessDenied
    case fileReadFailed(error: Error)
    case unsupportedFormat(actualFormat: String, supportedFormats: String)
    case sampleReadFailed(error: Error)
    case sampleConversionFailed
    case invalidChannel(requested: Int, available: Int)
    case noteCreationFailed(reason: String)
    case frequencyOutOfRange(min: Double, max: Double, actual: Double)
    case invalidPitch(pitch: String)
    case insufficientSamples(required: Int, actual: Int)   

    var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            return "Access to file was denied. Check permissions."
        case .fileReadFailed(let error):
            return "Failed to read audio file: \(error.localizedDescription)"
        case .unsupportedFormat(let actual, let supported):
            return "Unsupported format: \(actual). Supported: \(supported)."
        case .sampleReadFailed(let error):
            return "Failed to read audio samples: \(error.localizedDescription)"
        case .sampleConversionFailed:
            return "Failed to convert samples to float format."
        case .invalidChannel(let requested, let available):
            return "Invalid channel \(requested). Only \(available) channels available."
        case .noteCreationFailed(let reason):
            return "Failed to create note: \(reason)"
        case .frequencyOutOfRange(let min, let max, let actual):
            return String(
                format: "Frequency %.2f Hz is outside valid range (%.0f-%.0f Hz)",
                actual, min, max
            )
        case .invalidPitch(let pitch):
            return "Invalid pitch name: \(pitch). Use standard pitches (C, C#, D, etc.)"
        case .insufficientSamples(let required, let actual):
            return "Insufficient number of samples. Required: \(required), actual: \(actual)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileAccessDenied:
            return "Check the file permissions in System Settings > Privacy & Security > Files and Folders"
        case .unsupportedFormat:
            return "Convert the file to WAV or AIFF format using any audio converter"
        case .frequencyOutOfRange:
            return "Check your audio input for noise or try using a different recording"
        case .invalidPitch:
            return "Valid pitch names are: C, C#, D, D#, E, F, F#, G, G#, A, A#, B"
        case .noteCreationFailed:
            return "Verify the input frequency and try again. If problem persists, record a new sample"
        case .insufficientSamples:
            return "Increase the size of the input buffer or decrease FFT size"
        default:
            return nil
        }
    }
}
