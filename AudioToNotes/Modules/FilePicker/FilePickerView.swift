import SwiftUI

struct FilePickerView: View {
    @ObservedObject var viewModel: FilePickerViewModel
    @State private var isFileImporterPresented = false
    
    var body: some View {
        VStack(spacing: 40) {
            
            VStack(spacing: 16) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 56))
                    .foregroundColor(ColorPalette.primary)
                
                Text("Аудио в Ноты")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(ColorPalette.primary)
                
                Text("Загрузите аудиофайл для анализа")
                    .font(.title3)
                    .foregroundColor(ColorPalette.accent3)
            }
            
            Button(action: {
                isFileImporterPresented = true
            }) {
                HStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.1)
                    } else {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 26, weight: .medium))
                        Text(viewModel.isLoading ? "Загрузка..." : "Выбрать аудиофайл")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .padding(.vertical, 22)
                .padding(.horizontal, 60)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ColorPalette.primary,
                            ColorPalette.accent
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: ColorPalette.primary.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(viewModel.isLoading)
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.body)
                    .foregroundColor(ColorPalette.accent)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30) 
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result: result)
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .animation(.easeInOut, value: viewModel.errorMessage)
    }
    
    private func handleFileSelection(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                viewModel.loadAudioFile(from: url)
            }
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
        }
    }
}
