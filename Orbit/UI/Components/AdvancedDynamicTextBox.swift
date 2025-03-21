//
//  AdvancedDynamicTextBox.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-20.
//

import SwiftUI
import UIKit

struct AdvancedDynamicTextBox: View {
    @Binding var text: String
    let minHeight: CGFloat = 40
    let maxHeight: CGFloat = 200

    var body: some View {
        TextView(text: $text)
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(
                    Color.gray.opacity(0.3))
            )
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .animation(.easeInOut(duration: 0.2))
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isEditable = true
        //        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(
            top: 0, left: -4, bottom: 0, right: -4)
        textView.delegate = context.coordinator

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
#Preview {
    TextView(text: .constant("hi"))
}
