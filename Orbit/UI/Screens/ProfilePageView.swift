//
//  ProfilePageView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-12-18.
//
import SwiftUI

struct ProfilePageView: View {
    let user: UserModel
    @Environment(\.colorScheme) var colorScheme
    @State private var orbitAngle: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header with picture and orbiting interests
                ZStack {
                    // Background gradient
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    ColorPalette.accent(for: colorScheme)
                                        .opacity(0.2),
                                    ColorPalette.background(for: colorScheme),
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 150
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .scaleEffect(1.5)
                        .padding()

                    // Profile Picture
                    if let profileUrl = user.profilePictureUrl,
                        let url = URL(string: profileUrl)
                    {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(
                                        ColorPalette.accent(for: colorScheme),
                                        lineWidth: 2))
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(
                                    ColorPalette.secondaryText(for: colorScheme)
                                )
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme)
                            )
                            .overlay(
                                Circle().stroke(
                                    ColorPalette.accent(for: colorScheme),
                                    lineWidth: 2)
                            )
                    }

                    // Orbiting Activities
                    if let activities = user
                        .activitiesHobbies
                    {
                        ForEach(Array(activities.enumerated()), id: \.element) {
                            index, activity in
                            InterestOrbit(
                                interest: activity,
                                index: index,
                                totalCount: activities.count,
                                orbitAngle: orbitAngle
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    withAnimation(
                        .linear(duration: 20).repeatForever(autoreverses: false)
                    ) {
                        orbitAngle = 45
                    }
                }

                // User Info Sections
                VStack(alignment: .leading, spacing: 24) {
                    // Basic Info
                    Text(user.firstName + " " + (user.lastName ?? ""))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.text(for: colorScheme))

                    // Personal Preferences Section
                    let personalPrefs =
                        (user.activitiesHobbies ?? [])
                        + (user.friendActivities ?? [])

                    if !personalPrefs.isEmpty {
                        PreferenceSection(
                            title: "Personal Preferences",
                            items: personalPrefs
                        )
                    }

                    // Interaction Preferences Section
                    let interactions = (user.preferredMeetupType ?? []) + (user.convoTopics ?? [])
                    if !interactions.isEmpty {
                        PreferenceSection(
                            title: "Connection Style",
                            items: interactions
                        )
                    }

                    // Friendship Values Section
                    let friendshipValues = (user.friendshipValues ?? []) + (user.friendshipQualities ?? [])
                    if !friendshipValues.isEmpty {
                        PreferenceSection(
                            title: "Friendship Values",
                            items: friendshipValues
                        )
                    }
                }
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

#Preview {
    PreferenceSection(
        title: "hiii",
        items: [
            "1OldFlowLayout", "2OldFlowLayout", "3", "4", "5", "6", "7", "8",
            "9", "10",
        ])
}
