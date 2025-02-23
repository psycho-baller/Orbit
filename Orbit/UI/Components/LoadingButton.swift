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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 8)
                }
                Text(title)
                    .regularFont()
            }
            .padding()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(
                isEnabled
                    ? ColorPalette.accent(for: colorScheme)
                    : ColorPalette.accent(for: colorScheme).opacity(0.5)
            )
            .cornerRadius(10)
        }
        .disabled(!isEnabled || isLoading)
    }
}
