//
//  ProfileView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-10-19.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingBottomSheet = false
    @State private var selectedInterests: [String] = []
    @State private var orbitAngle: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                ZStack {
                    // Background gradient
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    ColorPalette.accent(for: colorScheme).opacity(0.2),
                                    ColorPalette.background(for: colorScheme)
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 150
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .scaleEffect(1.5)
                    .padding()
                    
                    // Profile Image
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2))
                    
                    // Orbiting Interests
                    if let interests = userViewModel.currentUser?.interests {
                        ForEach(Array(interests.enumerated()), id: \.element) { index, interest in
                            InterestOrbit(
                                interest: interest,
                                index: index,
                                totalCount: interests.count,
                                orbitAngle: orbitAngle
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        orbitAngle = 45 //Change position of interests
                    }
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 16) {
                    if let name = userViewModel.currentUser?.name {
                        Text(name)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    // Social Style Section
                    if let socialStyle = userViewModel.currentUser?.socialStyle {
                        PreferenceSection(title: "Social Style", items: socialStyle)
                    }
                    
                    // Interaction Preferences
                    if let preferences = userViewModel.currentUser?.interactionPreferences {
                        PreferenceSection(title: "How I Like to Connect", items: preferences)
                    }
                    
                    // Friendship Values
                    if let values = userViewModel.currentUser?.friendshipValues {
                        PreferenceSection(title: "What I Value in Friendships", items: values)
                    }
                }
                .padding()
                .background(ColorPalette.main(for: colorScheme))
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
        .background(ColorPalette.background(for: colorScheme))
    }
}

// Orbiting interest component
struct InterestOrbit: View {
    let interest: String
    let index: Int
    let totalCount: Int
    let orbitAngle: Double
    @Environment(\.colorScheme) var colorScheme
    @State private var floatOffset: CGFloat = 0
    
    // Interest to Icon mapping
    private func iconName(for interest: String) -> String {
        switch interest.lowercased() {
        case "space": return "moon.stars.fill"
        case "coding": return "chevron.left.forwardslash.chevron.right"
        case "music": return "music.note"
        case "art": return "paintbrush.fill"
        case "reading": return "book.fill"
        case "gaming": return "gamecontroller.fill"
        case "sports": return "figure.run"
        case "cooking": return "fork.knife"
        case "travel": return "airplane"
        case "movies": return "film"
        case "photography": return "camera.fill"
        case "writing": return "pencil"
        case "nature": return "leaf.fill"
        case "technology": return "desktopcomputer"
        case "fitness": return "figure.walk"
        default: return "star.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Circle with Icon
            ZStack {
                Circle()
                    .fill(ColorPalette.accent(for: colorScheme).opacity(0.8))
                    .shadow(color: ColorPalette.accent(for: colorScheme).opacity(0.3), radius: 5)
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
                        .fill(ColorPalette.accent(for: colorScheme).opacity(0.6))
                )
        }
        .modifier(OrbitEffect(angle: orbitAngle, index: index, total: totalCount))
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
        
        return content
            .offset(x: xOffset, y: yOffset)
            .animation(.spring(dampingFraction: 0.7), value: angle)
    }
}

// Preference section component
struct PreferenceSection: View {
    let title: String
    let items: [String]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
            
            FlowLayout(items: items) { item in
                Text(item)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ColorPalette.lightGray(for: colorScheme))
                    .foregroundColor(ColorPalette.text(for: colorScheme))
                    .clipShape(Capsule())
            }
        }
    }
}

// Flow layout for tags
struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(generateRows(), id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }
    
    private func generateRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        
        for item in items {
            rows[currentRow].append(item)
            if rows[currentRow].count >= 3 {
                rows.append([])
                currentRow += 1
            }
        }
        
        return rows
    }
}


// MARK: - Preview

#if DEBUG
    #Preview {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel.mock())

    }
#endif
