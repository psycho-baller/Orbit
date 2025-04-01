//
//  ChatTextBox.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-20.
//

import SwiftUI

struct ChatTextBox: View {
    @Binding var message: String
    let onSend: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            AdvancedDynamicTextBox(text: $message)
                .padding(.vertical, 12)
                .padding(.leading, 16)
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(
                            message.isEmpty
                                ? Color.accentColor.opacity(0.3)
                                : Color.accentColor
                        )
                        .frame(width: 36)
                    Image(systemName: "arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding([.trailing, .bottom], 16)
            }
            .disabled(message.isEmpty)
        }
        .background(
            // Apply the material background with only the top corners rounded.
            RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                .fill(.thinMaterial)
        )
        .foregroundColor(.primary)
        // Animate changes (such as height) when the message changes.
        .animation(.easeInOut(duration: 0.2), value: message)
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme

    ChatTextBox(message: .constant("Hello\nbro\nyo\nno"), onSend: {})
        .accentColor(ColorPalette.accent(for: colorScheme))
}
