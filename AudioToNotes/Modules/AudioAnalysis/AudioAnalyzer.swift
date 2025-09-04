import AVFoundation
import Accelerate

final class AudioAnalyzer {
    private let sampleRate: Double
    private let fftSize: Int
    private let fftSetup: FFTSetup

    
    init(sampleRate: Double, fftSize: Int = 2048) {
        self.sampleRate = sampleRate
        self.fftSize = fftSize
        self.fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Double(fftSize))), FFTRadix(kFFTRadix2))!
    }
    
    func analyze(audioFile: AudioFile) throws -> [Note] {
        guard !audioFile.samples.isEmpty else {
            throw AudioError.sampleReadFailed(error: NSError(domain: "No samples available", code: 0))
        }
        
        let chunkSize = fftSize
        var notes = [Note]()
        let sampleCount = audioFile.samples.count
        
        for i in stride(from: 0, to: sampleCount, by: chunkSize) {
            let endIndex = min(i + chunkSize, sampleCount)
            let chunk = Array(audioFile.samples[i..<endIndex])
            
            if let frequency = try? detectPitch(samples: chunk) {
                let startTime = Double(i) / sampleRate
                let duration = Double(chunk.count) / sampleRate
                
                if let note = try? Note.fromFrequency(frequency) {
                    var detectedNote = note
                    detectedNote.startTime = startTime
                    detectedNote.duration = duration
                    notes.append(detectedNote)
                }
            }
        }
        
        return mergeSimilarNotes(notes: notes)
    }
    
    private func detectPitch(samples: [Float]) throws -> Double {
        guard samples.count >= fftSize else {
            throw AudioError.insufficientSamples(required: fftSize, actual: samples.count)
        }

        // 1. Применяем оконную функцию Ханна
        var windowedSamples = [Float](repeating: 0, count: fftSize)
        var window = [Float](repeating: 0, count: fftSize)
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(0))
        
        // Копируем samples в windowedSamples (остальные — нули)
        for i in 0..<min(samples.count, fftSize) {
            windowedSamples[i] = samples[i]
        }
        
        // Умножаем на оконную функцию
        vDSP_vmul(windowedSamples, 1, window, 1, &windowedSamples, 1, vDSP_Length(fftSize))

        // 2. Подготовка FFT
        var real = [Float](repeating: 0, count: fftSize)
        var imag = [Float](repeating: 0, count: fftSize)
        var complexBuffer = DSPSplitComplex(realp: &real, imagp: &imag)

        // 3. Конвертируем в комплексный формат
        windowedSamples.withUnsafeBytes { ptr in
            let buffer = ptr.bindMemory(to: DSPComplex.self)
            vDSP_ctoz(buffer.baseAddress!, 2, &complexBuffer, 1, vDSP_Length(fftSize/2))
        }

        // 4. Выполняем FFT
        vDSP_fft_zrip(fftSetup, &complexBuffer, 1,
                      vDSP_Length(log2(Double(fftSize))),
                      FFTDirection(FFT_FORWARD))

        // 5. Вычисляем магнитуды
        var magnitudes = [Float](repeating: 0, count: fftSize/2)
        vDSP_zvmags(&complexBuffer, 1, &magnitudes, 1, vDSP_Length(fftSize/2))

        // 6. Находим пиковую частоту (с интерполяцией)
        var maxMagnitude: Float = 0
        var maxIndex: vDSP_Length = 0
        vDSP_maxvi(magnitudes, 1, &maxMagnitude, &maxIndex, vDSP_Length(fftSize/2))

        let lowerBin = max(1, Int(maxIndex) - 1)
        let upperBin = min(Int(maxIndex) + 1, magnitudes.count - 1)
        let y1 = magnitudes[lowerBin]
        let y2 = magnitudes[Int(maxIndex)]
        let y3 = magnitudes[upperBin]
        let delta = (y3 - y1) / (2.0 * (2.0 * y2 - y1 - y3))
        let interpolatedIndex = Double(maxIndex) + Double(delta)
        let frequency = interpolatedIndex * sampleRate / Double(fftSize)

        guard frequency > 20 && frequency < 2000 else {
            throw AudioError.frequencyOutOfRange(min: 20, max: 2000, actual: frequency)
        }

        return frequency
    }
    
    private func mergeSimilarNotes(notes: [Note]) -> [Note] {
        guard !notes.isEmpty else { return [] }
        
        var mergedNotes = [Note]()
        var currentNote = notes[0]
        
        for note in notes.dropFirst() {
            if note.pitch == currentNote.pitch &&
               note.startTime <= currentNote.startTime + currentNote.duration + 0.1 {
                // Объединяем ноты
                currentNote.duration = note.startTime + note.duration - currentNote.startTime
            } else {
                mergedNotes.append(currentNote)
                currentNote = note
            }
        }
        
        mergedNotes.append(currentNote)
        return mergedNotes
    }
}
