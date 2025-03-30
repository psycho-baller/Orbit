//
//  OrbitingInterests.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-29.
//

import SwiftUI

// Orbiting interest component
struct InterestOrbit: View {
    let interest: String
    let index: Int
    let totalCount: Int
    let orbitAngle: Double
    @Environment(\.colorScheme) var colorScheme
    @State private var floatOffset: CGFloat = 0

    // Interest to Icon mapping
    private func iconName(for activity: String) -> String {
        switch activity.lowercased() {
        case "hiking": return "figure.hiking"
        case "reading": return "book.fill"
        case "cooking": return "fork.knife"
        case "volunteering": return "heart.fill"
        case "photography": return "camera.fill"
        case "yoga": return "figure.mind.and.body"
        case "gaming": return "gamecontroller.fill"
        case "painting": return "paintbrush.fill"
        case "sports": return "figure.run"
        case "traveling": return "airplane"
        case "crafting": return "scissors"
        case "coding": return "chevron.left.forwardslash.chevron.right"
        case "music": return "music.note"
        case "meditation": return "sparkles"
        case "dancing": return "figure.dance"
        case "gardening": return "leaf.fill"
        default: return "star.fill"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Circle with Icon
            ZStack {
                Circle()
                    .fill(ColorPalette.accent(for: colorScheme).opacity(0.8))
                    .shadow(
                        color: ColorPalette.accent(for: colorScheme).opacity(
                            0.3), radius: 5
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: iconName(for: interest))
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            // Interest Text
            Text(interest)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(
                            ColorPalette.accent(for: colorScheme).opacity(0.6))
                )
        }
        .modifier(
            OrbitEffect(angle: orbitAngle, index: index, total: totalCount)
        )
        .offset(y: floatOffset)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.2)
            ) {
                floatOffset = 15
            }
        }
    }
}

// Orbit animation modifier
struct OrbitEffect: ViewModifier {
    let angle: Double
    let index: Int
    let total: Int

    func body(content: Content) -> some View {
        let baseRadius: CGFloat = 150
        let angleOffset = (360.0 / Double(total)) * Double(index)
        let currentAngle = angle + angleOffset
        let xOffset = baseRadius * cos(currentAngle * .pi / 180)
        let yOffset = baseRadius * sin(currentAngle * .pi / 180)

        return
            content
            .offset(x: xOffset, y: yOffset)
            .animation(.spring(dampingFraction: 0.7), value: angle)
    }
}

// Orbit container that manages its own animation
struct OrbitContainer: View {
    let interests: [String]
    
    // Internal state for animation
    @State private var orbitAngle: Double = 0
    
    var body: some View {
        ZStack {
            ForEach(Array(interests.enumerated()), id: \.element) { index, activity in
                InterestOrbit(
                    interest: activity,
                    index: index,
                    totalCount: interests.count,
                    orbitAngle: orbitAngle
                )
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 20).repeatForever(autoreverses: false)
            ) {
                orbitAngle = 45
            }
        }
    }
}

#if DEBUG
struct OrbitComponentsPreview: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            // Center circle to represent profile picture
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 120, height: 120)
            
            // Sample orbiting interests
            OrbitContainer(interests: ["Hiking", "Reading", "Cooking", "Gaming", "Music"])
        }
    }
}

#Preview {
    OrbitComponentsPreview()
}
#endif
