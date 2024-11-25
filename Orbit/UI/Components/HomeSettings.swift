//
//  HomeSettings.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-25.
//

import SwiftUI

struct HomeSettings: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()

            // Add your configuration options here
            Toggle("Enable Notifications", isOn: .constant(true))
                .padding()

            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
