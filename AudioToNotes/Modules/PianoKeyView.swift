import SwiftUI

struct PianoKeyView: View {
    let noteName: String
    let isPressed: Bool
    let isBlackKey: Bool
    let color: Color
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(isBlackKey ? Color.black : Color.white)
                .overlay(
                    Rectangle()
                        .stroke(Color.gray, lineWidth: 1)
                )
                .overlay(
                    isPressed ? color.opacity(0.7) : Color.clear
                )
                .frame(
                    width: isBlackKey ? 24 : 40,
                    height: isBlackKey ? 70 : 120
                )
            
            if !isBlackKey {
                Text(noteName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isPressed ? .white : .black)
                    .padding(.bottom, 4)
            }
        }
        .zIndex(isBlackKey ? 1 : 0)
    }
}
