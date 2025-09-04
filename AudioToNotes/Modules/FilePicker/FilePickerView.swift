import SwiftUI

struct FilePickerView: View {
    @ObservedObject var viewModel: FilePickerViewModel
    @State private var isFileImporterPresented = false
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                isFileImporterPresented = true
            }) {
                HStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "waveform")
                            .font(.system(size: 18))
                    }
                    
                    Text(viewModel.isLoading ? "Загрузка..." : "Выбрать аудиофайл")
                        .font(.headline)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 28)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.isLoading)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
                    .transition(.opacity)
            }
        }
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
