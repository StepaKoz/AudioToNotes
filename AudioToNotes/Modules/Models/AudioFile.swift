import AVFoundation
import Foundation

struct AudioFile: Equatable {
    let url: URL
    let name: String
    let duration: TimeInterval
    let sampleRate: Double
    let channelCount: UInt32
    let samples: [Float]
    let format: AVAudioFormat
    
    init(url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw AudioError.fileAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let audioFile: AVAudioFile
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            throw AudioError.fileReadFailed(error: error)
        }
        let format = audioFile.processingFormat

        let frameCount = Int(audioFile.length)
        let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        )!
        
        do {
            try audioFile.read(into: buffer)
        } catch {
            throw AudioError.sampleReadFailed(error: error)
        }
        
        guard let floatChannelData = buffer.floatChannelData else {
            throw AudioError.sampleConversionFailed
        }
        
        self.url = url
        self.name = url.lastPathComponent
        self.duration = Double(frameCount) / format.sampleRate
        self.sampleRate = format.sampleRate
        self.channelCount = format.channelCount
        self.format = format
        self.samples = Array(UnsafeBufferPointer(
            start: floatChannelData[0],
            count: frameCount
        ))
    }
    
    func getSamples(forChannel channel: Int = 0) throws -> [Float] {
        guard channel >= 0 && channel < Int(channelCount) else {
            throw AudioError.invalidChannel(
                requested: channel,
                available: Int(channelCount)
            )
        }
        return samples
    }
}
