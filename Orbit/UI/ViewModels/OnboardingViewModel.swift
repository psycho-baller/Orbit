//
//  OnboardingViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-10-30.
//

import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var reasons: [ReasonOption] = [
        ReasonOption(title: "Looking for casual meetups and activities"),
        ReasonOption(title: "Finding like-minded friends to share hobbies"),
        ReasonOption(title: "Building a supportive social circle"),
        ReasonOption(title: "Exploring new social experiences"),
        ReasonOption(title: "Connecting with people in my local area"),
        ReasonOption(title: "Joining group events and outings"),
        ReasonOption(title: "Meeting people for intellectual or deep conversations"),
        ReasonOption(title: "Creating lasting friendships"),
        ReasonOption(title: "Just exploring, open to various connections")
    ]
    
    func toggleSelection(for reason: ReasonOption) {
        if let index = reasons.firstIndex(where: { $0.id == reason.id }) {
            reasons[index].isSelected.toggle()
        }
    }
}

