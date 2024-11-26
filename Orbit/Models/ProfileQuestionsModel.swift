//
//  ProfileQuestionsModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-10-30.
//

import Foundation

struct QuestionOption: Identifiable {
    let id = UUID()
    let title: String
    var isSelected: Bool = false
}

struct Question: Identifiable {
    let id = UUID()
    let text: String
    var options: [QuestionOption]
}
