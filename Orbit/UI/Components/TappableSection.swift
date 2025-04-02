//
//  TappableSection.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-31.
//
import SwiftUI

struct TappableSection<Content: View>: View {
    var title: String?
    var action: () -> Void
    @ViewBuilder var content: () -> Content
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                if let title = title {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        
//                        Spacer()
//
//                        Image(systemName: "pencil")
//                            .foregroundColor(ColorPalette.accent(for: colorScheme))
//                            .font(.system(size: 14))
                    }
                }
                
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(ColorPalette.lightGray(for: colorScheme).opacity(0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorPalette.accent(for: colorScheme).opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TappableProfileTagSection: View {
    let title: String
    let items: [String]
    var onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TappableSection(title: title, action: onTap) {
            if items.isEmpty {
                Text("Tap to add \(title.lowercased())")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(
                        ColorPalette.secondaryText(for: colorScheme).opacity(0.7)
                    )
                    .padding(.vertical, 8)
            } else {
                FlowLayout(items: items) { item in
                    Text(item.capitalized)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    ColorPalette.accent(for: colorScheme)
                                        .opacity(0.2))
                        )
                        .foregroundColor(
                            ColorPalette.accent(for: colorScheme))
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TappableSection(title: "Personal Information", action: {}) {
            Text("This is some content")
                .foregroundColor(.primary)
        }
        
        TappableProfileTagSection(
            title: "Interests",
            items: ["hiking", "reading", "cooking"],
            onTap: {}
        )
        
        TappableProfileTagSection(
            title: "Empty Section",
            items: [],
            onTap: {}
        )
    }
    .padding()
}
