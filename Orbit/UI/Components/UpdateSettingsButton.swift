//
//  UpdateSettingsButton.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-25.
//


import SwiftUI

struct UpdateSettingsButton: View  {

    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: {
            appState.isShowingHomeSettings = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape")
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Update")
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
        }
    }
}
#Preview {
    UpdateSettingsButton()
}
