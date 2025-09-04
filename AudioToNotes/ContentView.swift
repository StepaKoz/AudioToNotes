import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var filePickerVM = FilePickerViewModel()
    @State private var showAnalysisControls = false
    
    var body: some View {
        ZStack {
            // Фоновый градиент
            backgroundGradient
            
            VStack(spacing: 20) {
                // Заголовок
                headerSection
                
                // Основной контент
                mainContentSection
                
                Spacer()
            }
            .padding(.top, 30)
        }
        .frame(minWidth: 400, minHeight: 500)
        .animation(.easeInOut, value: filePickerVM.audioFile)
        .animation(.easeInOut, value: filePickerVM.detectedNotes)
    }
    
    // MARK: - Компоненты
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [ColorPalette.secondary.opacity(0.2), .white]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform.path")
                .font(.system(size: 42))
                .foregroundColor(ColorPalette.primary)
            
            Text("Аудио в Ноты")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            Text("Загрузите аудиофайл для анализа")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var mainContentSection: some View {
        VStack(spacing: 24) {
            FilePickerView(viewModel: filePickerVM)
                .padding(.horizontal, 40)
            
            if let file = filePickerVM.audioFile {
                fileInfoSection(file: file)
                analysisControlsSection
                notesVisualizationSection
            }
        }
    }
    
    private func fileInfoSection(file: AudioFile) -> some View {
        VStack(spacing: 12) {
            Divider()
                .background(ColorPalette.primary.opacity(0.3))
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Файл готов к анализу")
                        .font(.headline)
                }
                
                fileInfoRow(icon: "info.circle", text: file.name)
                fileInfoRow(icon: "clock", text: "Длительность: \(String(format: "%.1f", file.duration)) сек")
                fileInfoRow(icon: "waveform.path", text: "Частота: \(Int(file.sampleRate)) Гц")
                fileInfoRow(icon: "speaker.wave.2", text: "Каналы: \(file.channelCount)")
            }
            .padding()
            .background(ColorPalette.secondary.opacity(0.2))
            .cornerRadius(12)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    private var analysisControlsSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                filePickerVM.analyzeAudio()
            }) {
                HStack {
                    if filePickerVM.isAnalyzing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(filePickerVM.isAnalyzing ? "Идет анализ..." : "Анализировать аудио")
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(filePickerVM.isAnalyzing)
            .padding(.horizontal, 40)
            
            if filePickerVM.isAnalyzing {
                VStack {
                    ProgressView(value: filePickerVM.analysisProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: ColorPalette.primary))
                    
                    Text("Анализ: \(Int(filePickerVM.analysisProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    private var notesVisualizationSection: some View {
        Group {
            if !filePickerVM.detectedNotes.isEmpty {
                VStack(spacing: 8) {
                    Text("Обнаруженные ноты")
                        .font(.headline)
                    
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(filePickerVM.detectedNotes) { note in
                                NoteRowView(note: note)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 200)
                }
                .transition(.opacity)
            } else if filePickerVM.errorMessage != nil {
                errorSection
            }
        }
    }
    
    private var errorSection: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(ColorPalette.accent)
                .font(.system(size: 24))
            
            Text(filePickerVM.errorMessage ?? "Неизвестная ошибка")
                .foregroundColor(ColorPalette.accent)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(ColorPalette.accent.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 40)
    }
    
    private func fileInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 20)
            Text(text)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

