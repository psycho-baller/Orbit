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

    init(
        alignment: MenuAlignment = .under, @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
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
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .offset(x: xOffsetForAlignment(), y: 45),  // Positioning menu content below the label
                alignment: overlayAlignment()
            )
        }
    }

    // Determines the alignment point of the overlay content
    private func overlayAlignment() -> Alignment {
        switch alignment {
        case .leading: return .topLeading
        case .trailing: return .topTrailing
        case .under: return .top  // Centered directly under the label
        }
    }

    // Determines the x-offset for the content position relative to the label
    private func xOffsetForAlignment() -> CGFloat {
        switch alignment {
        case .leading:
            return 0  // Align left edge of overlay with left edge of label
        case .trailing:
            return 0  // Align right edge of overlay with right edge of label
        case .under:
            return 0  // Centered alignment under the label
        }
    }
}

struct CustomMenuPreview: View {
    @State private var number: Double = 25

    var body: some View {
        CustomMenu(
            alignment: .trailing,
            label: { Text("hi") },
            content: {
                Slider(value: $number, in: 1...50, step: 1)
                    .padding(.horizontal)
                    .frame(width: 150)
            }
        )
        .padding()  // Optional: Add padding to the CustomMenu for better appearance
    }
}

#Preview {
    CustomMenuPreview()
}
