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
    @Binding var isExpanded: Bool

    init(
        alignment: MenuAlignment = .under,
        isExpanded: Binding<Bool>,  // Accept a binding for isMenuExpanded
        @ViewBuilder label: () -> Label, @ViewBuilder content: () -> Content
    ) {
        self.label = label()
        self.content = content()
        self.alignment = alignment
        self._isExpanded = isExpanded  // Initialize binding
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
                            .zIndex(1000)  // Set a high zIndex for the overlay content
                            .allowsHitTesting(true)  // Explicitly allow hit testing
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .offset(x: xOffsetForAlignment(), y: 45),
                alignment: overlayAlignment()
            )
        }
    }

    private func overlayAlignment() -> Alignment {
        switch alignment {
        case .leading: return .topLeading
        case .trailing: return .topTrailing
        case .under: return .top
        }
    }

    private func xOffsetForAlignment() -> CGFloat {
        switch alignment {
        case .leading:
            return 0
        case .trailing:
            return 0
        case .under:
            return 0
        }
    }

    private func maxWidthForAlignment() -> CGFloat? {
        UIScreen.main.bounds.width * 0.5  // Restrict width to avoid overlap
    }
}

struct CustomMenuPreview: View {
    @State private var number: Double = 25
    @State private var isMenuExpanded = false

    var body: some View {
        CustomMenu(
            alignment: .trailing,
            isExpanded: $isMenuExpanded,
            label: { Text("hi") },
            content: {
                VStack {
                    Button {
                        number = 1
                    } label: {
                        Text("Reset")
                            .foregroundColor(.red)
                    }
                    Slider(value: $number, in: 1...50, step: 1)
                        .padding(.horizontal)
                        .frame(width: 150)
                }
            }
        )
        .padding()  // Optional: Add padding to the CustomMenu for better appearance
    }
}

#Preview {
    CustomMenuPreview()
}
