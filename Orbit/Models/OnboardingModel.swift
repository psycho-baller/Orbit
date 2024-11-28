//
//  OnboardingModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-10-30.
//

import Foundation

struct ReasonOption: Identifiable {
    let id = UUID()
    let title: String
    var isSelected: Bool = false
}
