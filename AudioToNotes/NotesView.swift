import SwiftUI

struct NotesView: View {
    let notes: [Note]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(notes) { note in
                    NoteRowView(note: note)
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }
}


struct NoteView: View {
    let note: Note
    
    var body: some View {
        HStack {
            Text(note.fullName)
                .font(.system(.title, design: .rounded))
                .frame(width: 60, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text("\(String(format: "%.1f", note.frequency)) Hz")
                    .font(.caption)
                
                Text("\(String(format: "%.2f", note.startTime)) - \(String(format: "%.2f", note.startTime + note.duration)) сек")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Rectangle()
                .fill(colorForNote(note.pitch))
                .frame(width: 8, height: 30)
                .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(ColorPalette.secondary.opacity(0.2))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
    
    private func colorForNote(_ pitch: String) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
        let noteIndex = Note.validPitches.firstIndex(of: pitch) ?? 0
        return colors[noteIndex % colors.count]
    }
}
