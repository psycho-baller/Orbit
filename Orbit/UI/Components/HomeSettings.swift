//
//  HomeSettings.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-25.
//

import SwiftUI

struct HomeSettings: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM: UserViewModel

    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .padding()
//            Toggle(
//                "Receive meetup requests from other people",
//                isOn: Binding(
//                    get: { userVM.currentUser? ?? false },
//                    set: { _ in
//                        Task {
//                            await userVM.toggleIsInterestedToMeet()
//                        }
//                    }
//                )
//            )
//            .font(.headline)
        }
        .padding()
    }
}
#if DEBUG
    #Preview {
        HomeSettings()
            .environmentObject(UserViewModel.mock())
    }
#endif
