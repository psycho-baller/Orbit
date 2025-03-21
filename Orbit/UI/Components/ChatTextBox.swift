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
//        HStack {
//            TextField("Type a message...", text: $message)
//                .padding(.vertical, 12)
//                .padding(.leading, 16)
//
//            if message.isEmpty {
//                Button(action: onSend) {
//                    Image(systemName: "paperplane.fill")
//                        .font(.title2)
//                        .padding(.trailing, 16)
//                        .foregroundColor(.accentColor)
//                }
//            }
//        }
//        .background(
//            // Apply the material background with only the top corners rounded.
//            RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
//                .fill(.ultraThinMaterial)
//        )
//        .foregroundColor(.primary)

    }
}

struct ChatTextBox_Previews: PreviewProvider {
    static var previews: some View {
        ChatTextBox(message: .constant(""), onSend: {})
    }
}
