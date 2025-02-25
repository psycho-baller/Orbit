//
//  UserLinksView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-25.
//

import SwiftUI

struct UserLinksView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedLinks: Set<String> = []
    let linkOptions = [
        "Instagram", "X", "LinkedIn", "TikTok", "Bluesky", "Other",
    ]

    var body: some View {
        Form {
            Section(
                header: Text(
                    "What are some links you'd like to share with other Astronauts?"
                )
            ) {
                ForEach(linkOptions, id: \.self) { option in
                    MultipleSelectionRow(
                        title: option,
                        isSelected: selectedLinks.contains(option)
                    ) {
                        if selectedLinks.contains(option) {
                            selectedLinks.remove(option)
                        } else {
                            selectedLinks.insert(option)
                        }
                    }
                }
            }
        }
        .navigationTitle("Links")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish") {
                    Task {
                        // Convert selected strings to your UserLinkModel objects as needed.
                        userVM.currentUser?.userLinks = selectedLinks.map {
                            UserLinkModel(platform: .instagram, value: $0)
                        }
                        await userVM.saveOnboardingData(markComplete: true)
                    }
                }
            }
        }
    }
}
