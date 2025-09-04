import SwiftUI

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        HStack {
            Text(note.fullName)
                .font(.system(.title3, design: .rounded))
                .frame(width: 60, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(String(format: "%.1f", note.frequency)) Hz")
                    .font(.caption)
                
                Text("\(formatTime(note.startTime)) - \(formatTime(note.startTime + note.duration))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(noteColor)
                .frame(width: 8, height: 30)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(ColorPalette.secondary.opacity(0.6))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var noteColor: Color {
        let index = Note.validPitches.firstIndex(of: note.pitch) ?? 0
        return ColorPalette.noteColors[index % ColorPalette.noteColors.count]
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter.string(from: seconds) ?? "0:00"
    }
}

