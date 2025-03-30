//
//  AdvancedDynamicTextBox.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-20.
//

import SwiftUI
import UIKit

// MARK: - UIKit-backed TextView
struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(
            top: 8, left: 4, bottom: 8, right: 4)
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

// MARK: - Advanced Dynamic Text Input with Integrated Send Button
struct AdvancedDynamicTextInput: View {
    @Binding var text: String
    let minHeight: CGFloat = 40
    let maxHeight: CGFloat = 200
    var sendAction: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Our dynamic text editor.
            TextView(text: $text)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .background(Color.clear)
            if !text.isEmpty {
                Button(action: sendAction) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .padding(8)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: text)
    }
}

// MARK: - Preview Example
struct AdvancedDynamicTextBox_Previews: PreviewProvider {
    @State static var text: String =
        "Hello, this is a dynamic text input.\nIt supports multiple lines."
    static var previews: some View {
        AdvancedDynamicTextInput(text: $text) {
            // Send action example
            print("Send tapped with text: \(text)")
            text = ""
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
