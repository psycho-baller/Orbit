//
//  InteractionPreferencesViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import Foundation

class InteractionPreferencesViewModel: ObservableObject {
    @Published var questions: [Question] = [
        Question(
            text: "When it comes to planning meetups, what do you prefer?",
            options: [
                "Spontaneous",
                "Some Planning ",
                "Well-Organized",
                "Flexible"
            ].map { QuestionOption(title: $0) }
        ),
        Question(
            text: "How do you prefer interacting with new friends?",
            options: [
                "Texting/Chatting",
                "Voice Calls",
                "In-Person Hangouts",
                "Group Activities",
                "Exploring New Places",
                "Virtual Hangouts"
            ].map { QuestionOption(title: $0) }
        ),
        Question(
            text: "Do you typically start conversations or wait for others to approach you?",
            options: [
                "I usually start conversations",
                "I prefer waiting for others",
                "Depends on the situation"
            ].map { QuestionOption(title: $0) }
        )
    ]
    
    // Function to toggle the selection state of a particular option within a question
    func toggleSelection(for option: QuestionOption, in question: Question) {
        if let questionIndex = questions.firstIndex(where: { $0.id == question.id }),
           let optionIndex = questions[questionIndex].options.firstIndex(where: { $0.id == option.id }) {
            questions[questionIndex].options[optionIndex].isSelected.toggle()
        }
    }
}