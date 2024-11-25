//
//  OffCampusView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-25.
//

import SwiftUI

struct OffCampusView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {

        VStack {
            Text("You are currently off-campus")
                .font(.title)
                .fontWeight(.heavy)
            //                .foregroundColor(ColorPalette.accent(for: colorScheme))
            Text(
                "Your location is currently not actively tracked and is not being shared to anyone"
            )
            .padding()
            .font(.title3)
            .fontWeight(.semibold)
        }
        .multilineTextAlignment(.center)
    }
}
#Preview {
    OffCampusView()

}
