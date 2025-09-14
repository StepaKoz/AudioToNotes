import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var filePickerVM = FilePickerViewModel()
    @State private var showAnalysisControls = false
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 30) {
                mainContentSection
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .frame(minWidth: 450, minHeight: 600)
        .animation(.easeInOut, value: filePickerVM.audioFile)
        .animation(.easeInOut, value: filePickerVM.detectedNotes)
    }
    
    private var backgroundView: some View {
        ColorPalette.secondary
            .opacity(0.95)
            .edgesIgnoringSafeArea(.all)
    }
    
    private var mainContentSection: some View {
        VStack(spacing: 28) {
            FilePickerView(viewModel: filePickerVM)
                .padding(.horizontal, 50)
            
            if let file = filePickerVM.audioFile {
                fileInfoSection(file: file)
                analysisControlsSection
                notesVisualizationSection
            }
        }
    }
    
    private func fileInfoSection(file: AudioFile) -> some View {
        VStack(spacing: 16) {
            Divider()
                .background(ColorPalette.primary.opacity(0.4))
                .padding(.horizontal, 50)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorPalette.accent2)
                        .font(.title3)
                    Text("Файл готов к анализу")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                fileInfoRow(icon: "info.circle", text: file.name)
                fileInfoRow(icon: "clock", text: "Длительность: \(String(format: "%.1f", file.duration)) сек")
                fileInfoRow(icon: "waveform.path", text: "Частота: \(Int(file.sampleRate)) Гц")
                fileInfoRow(icon: "speaker.wave.2", text: "Каналы: \(file.channelCount)")
            }

            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorPalette.secondary.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private var analysisControlsSection: some View {
        VStack(spacing: 20) {
            Button(action: {
                filePickerVM.analyzeAudio()
            }) {
                HStack {
                    if filePickerVM.isAnalyzing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    }
                    Text(filePickerVM.isAnalyzing ? "Идет анализ..." : "Анализировать аудио")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
            }
            .buttonStyle(.borderedProminent)
            .tint(ColorPalette.primary)
            .disabled(filePickerVM.isAnalyzing)
            .padding(.horizontal, 50)
            
            if filePickerVM.isAnalyzing {
                VStack {
                    ProgressView(value: filePickerVM.analysisProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: ColorPalette.primary))

                        .scaleEffect(y: 1.5)
                    
                    Text("Анализ: \(Int(filePickerVM.analysisProgress * 100))%")
                        .font(.body)
                        .foregroundColor(ColorPalette.accent3)
                }
                .padding(.horizontal, 50)
            }
        }
    }
    
    private var notesVisualizationSection: some View {
        Group {
            if !filePickerVM.detectedNotes.isEmpty {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text("Обнаруженные ноты")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.accent3)
                        
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(filePickerVM.detectedNotes) { note in
                                    NoteRowView(note: note)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 220)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ColorPalette.secondary.opacity(0.8))
                                .shadow(color: ColorPalette.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                    }
                    
                    PianoView(detectedNotes: filePickerVM.detectedNotes)
                }
                .transition(.opacity)
            } else if filePickerVM.errorMessage != nil {
                errorSection
            }
        }
    }
    
    private var errorSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(ColorPalette.accent)
                .font(.system(size: 28))
            
            Text(filePickerVM.errorMessage ?? "Неизвестная ошибка")
                .font(.body) 
                .foregroundColor(ColorPalette.accent3)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.accent.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorPalette.accent.opacity(0.4), lineWidth: 1.5)
                )
        )
        .padding(.horizontal, 50)
    }
    
    private func fileInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24) 
                .foregroundColor(ColorPalette.primary)
                .font(.body)
            Text(text)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .font(.body)
        .foregroundColor(ColorPalette.accent3)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

