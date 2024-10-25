//
//  CustomMenu.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-25.

import SwiftUI

struct CustomMenu<Label: View, Content: View>: View {
    enum MenuAlignment {
        case leading, trailing, under
    }

    let label: Label
    let content: Content
    let alignment: MenuAlignment
    @State private var isExpanded = false

    init(alignment: MenuAlignment = .under, @ViewBuilder label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
        self.alignment = alignment
    }

    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                label
            }
            .overlay(
                VStack(alignment: .leading, spacing: 8) {
                    if isExpanded {
                        content
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .frame(maxWidth: maxWidthForAlignment())
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .offset(x: xOffsetForAlignment(), y: 45), // Positioning content below the label with custom horizontal offset
                alignment: .topLeading
            )
        }
    }

    // Determines the x-offset based on alignment
    private func xOffsetForAlignment() -> CGFloat {
        switch alignment {
        case .leading:
            return -UIScreen.main.bounds.width / 2 + 20 // Align to left side of screen with padding
        case .trailing:
            return UIScreen.main.bounds.width / 2 - 100 // Align to right side of screen with padding
        case .under:
            return 0 // Centered alignment under the label
        }
    }
    
    // Sets a max width based on the alignment
    private func maxWidthForAlignment() -> CGFloat? {
        switch alignment {
        case .leading, .trailing:
            return UIScreen.main.bounds.width * 0.5 // Restrict width for side alignment
        case .under:
            return nil // Flexible width for centered alignment
        }
    }
}

#Preview {

    CustomMenu(
        alignment: .trailing,
        label: { Text("hi") },
        content: {
            Text("Hello")
            Text("World")
        }
    )
}
