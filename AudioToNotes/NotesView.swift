import SwiftUI

struct NotesView: View {
    let notes: [Note]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(notes) { note in
                    NoteRowView(note: note)
                        .padding(.vertical, 8)
                }
            }
            .padding(20)

        }
    }
}

struct NoteView: View {
    let note: Note
    var body: some View {
        HStack {
            Text(note.fullName)

                .font(.system(.title2, design: .rounded))
                .frame(width: 70, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text("\(String(format: "%.1f", note.frequency)) Hz")
                    .font(.callout)
                
                Text("\(String(format: "%.2f", note.startTime)) - \(String(format: "%.2f", note.startTime + note.duration)) сек")
                    .font(.caption)
                    .foregroundColor(ColorPalette.accent3.opacity(0.8))
            }
            
            Spacer()
            
            Rectangle()
                .fill(colorForNote(note.pitch))
                .frame(width: 10, height: 35)
                .cornerRadius(5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(ColorPalette.secondary.opacity(0.3))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
    
    private func colorForNote(_ pitch: String) -> Color {
        let colors = ColorPalette.noteColors
        let noteIndex = Note.validPitches.firstIndex(of: pitch) ?? 0
        return colors[noteIndex % colors.count]
    }
}
