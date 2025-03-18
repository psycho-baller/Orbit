//
//  LoadingButton.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-22.
//

import SwiftUI

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    let icon: String?
    init(
        title: String,
        isLoading: Bool,
        isEnabled: Bool,
        action: @escaping () -> Void,
        icon: String? = nil
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
        self.icon = icon
    }
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .primary)
                        )
                        .padding(.trailing, 8)
                        .opacity(isLoading ? 1 : 0)
                        .frame(
                            width: isLoading ? 20 : 0,
                            height: isLoading ? 20 : 0
                        )
                        .animation(.easeInOut(duration: 0.3), value: isLoading)

                    if let icon = icon, !icon.isEmpty {
                        Image(systemName: icon)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .opacity(isLoading ? 0 : 1)
                            .frame(
                                width: isLoading ? 0 : 20,
                                height: isLoading ? 0 : 20
                            )  // Prevents layout shift
                            .animation(
                                .easeInOut(duration: 0.3), value: isLoading)
                    }
                }
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding()
            .foregroundColor(.primary.opacity((isLoading) ? 0.5 : 1))
            //            .frame(maxWidth: .infinity, maxHeight: 50)
            //            .background(
            //                isEnabled
            //                    ? ColorPalette.accent(for: colorScheme)
            //                    : ColorPalette.accent(for: colorScheme).opacity(0.5)
            //            )
            .background(.ultraThinMaterial)
            .cornerRadius(10)
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    @Previewable @State var isLoading = false
    @Previewable @State var isEnabled = true

    return VStack(spacing: 16) {
        LoadingButton(
            title: "Retry",
            isLoading: isLoading,
            isEnabled: isEnabled,
            action: {
                isLoading.toggle()  // ✅ Toggle loading state
                isEnabled.toggle()  // ✅ Toggle enabled state

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false  // ✅ Reset after delay
                    isEnabled = true
                }
            },
            icon: "arrow.trianglehead.2.counterclockwise"
        )
    }
    .padding()
}
