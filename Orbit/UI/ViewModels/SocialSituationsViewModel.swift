//
//  SocialSituationsViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import Foundation

class SocialSituationsViewModel: ObservableObject {
    @Published var questions: [Question] = [
        Question(
            text: "When you meet new people, how do you usually feel?",
            options: [
                "Excited", "Curious", "Nervous", "Neutral",
                "Reserved", "Comfortable"
            ].map { QuestionOption(title: $0) }
        ),
        Question(
            text: "If you’re at a social event, what role do you find yourself taking?",
            options: [
                "The Planner", "The Social Butterfly", "The Listener",
                "The Helper", "The Observer", "The Icebreaker"
            ].map { QuestionOption(title: $0) }
        ),
        Question(
            text: "How often would you like to connect with new people?",
            options: [
                "Frequently", "Occasionally",
                "Rarely", "No preference"
            ].map { QuestionOption(title: $0) }
        )
    ]
    
    func toggleSelection(for option: QuestionOption, in question: Question) {
        if let questionIndex = questions.firstIndex(where: { $0.id == question.id }),
           let optionIndex = questions[questionIndex].options.firstIndex(where: { $0.id == option.id }) {
            questions[questionIndex].options[optionIndex].isSelected.toggle()
        }
    }
}
