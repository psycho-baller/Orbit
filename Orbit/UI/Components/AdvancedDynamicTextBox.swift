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
    // The dynamic height will be updated by the underlying UITextView.
    @State private var dynamicHeight: CGFloat =
        UIFont.preferredFont(forTextStyle: .body).lineHeight + 16  // Default: one line + vertical insets

    var body: some View {
        TextView(text: $text, calculatedHeight: $dynamicHeight)
            .frame(height: dynamicHeight)
            .background(Color.clear)  // transparent background
            .animation(.easeInOut(duration: 0.2), value: dynamicHeight)
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false  // allow expansion
        textView.isEditable = true
        textView.backgroundColor = .clear
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textContainerInset = UIEdgeInsets(
            top: 8, left: 4, bottom: 8, right: 4)
        textView.delegate = context.coordinator
        // Lower the horizontal compression resistance to let SwiftUI decide the width.
        textView.setContentCompressionResistancePriority(
            .defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        // Update height on the next runloop to let the text view layout its text.
        DispatchQueue.main.async {
            let size = uiView.sizeThatFits(
                CGSize(width: uiView.frame.size.width, height: .infinity))
            if self.calculatedHeight != size.height {
                self.calculatedHeight = size.height
            }
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
            let size = textView.sizeThatFits(
                CGSize(width: textView.frame.size.width, height: .infinity))
            if parent.calculatedHeight != size.height {
                DispatchQueue.main.async {
                    self.parent.calculatedHeight = size.height
                }
            }
        }
    }
}
// MARK: - Preview Example
struct AdvancedDynamicTextBox_Previews: PreviewProvider {
    @State static var text: String =
        "Hello, this is a dynamic text input.\nIt supports multiple lines."
    static var previews: some View {
        AdvancedDynamicTextBox(text: $text)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
