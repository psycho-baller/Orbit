//
//  FriendshipValuesViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import Foundation

class FriendshipValuesViewModel: ObservableObject {
    @Published var questions: [Question] = [
        Question(
            text: "What do you value most in a friendship?",
            options: [
                "Adventure", "Humor", "Loyalty", "Honesty", "Kindness",
                "Respect", "Similar Interests", "Mutual Support", "Fun Activities Together"
            ].map { QuestionOption(title: $0) }
        ),
        Question(
            text: "Which of these best describe your ideal friendship?",
            options: [
                "Mentorship", "Supportive", "Light-hearted", "Goal-Oriented",
                "Adventure-Driven", "Family-Like", "Intellectual", "Balanced",
                "Encouraging", "Humorous"
            ].map { QuestionOption(title: $0) }
        ),
        Question(
            text: "What qualities do you look for in someone you’d like to meet?",
            options: [
                "Good Listener", "Outgoing", "Empathetic", "Reliable", "Intelligent",
                "Creative", "Funny", "Open-Minded", "Positive", "Thoughtful"
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
