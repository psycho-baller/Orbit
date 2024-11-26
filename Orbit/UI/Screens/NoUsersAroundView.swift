//
//  NoUsersAroundView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-25.
//

import SwiftUI

struct NoUsersAroundView: View {
    @State private var animate = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.5),  // Outer edge visible
                            Color.blue.opacity(0.1),  // Fades inward
                            Color.blue.opacity(0.05),
                            Color.blue.opacity(0.025),
                            Color.clear,  // Inner edge invisible
                        ]),
                        center: .center,
                        startRadius: 60,  // Inner edge starts fading
                        endRadius: 120  // Outer edge ends fading
                    )
                )
                .scaleEffect(animate ? 3 : 0.1)  // Expands outward
                .opacity(animate ? 0 : 1)  // Fades out
                .animation(
                    .easeOut(duration: 2.5).repeatForever(autoreverses: false),
                    value: animate
                )
            VStack(spacing: 26) {
                Text("No one in your Orbit😔")
                    .font(.title)
                    .fontWeight(.heavy)
                // TODO: acc make this work
                Text("But there are 3 users in Mac hall!")
                    .font(.title3)
                    .fontWeight(.semibold)
                UpdateSettingsButton()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animate = true
        }
    }
}
#Preview {
    NoUsersAroundView()
        .environmentObject(AppState())
}
