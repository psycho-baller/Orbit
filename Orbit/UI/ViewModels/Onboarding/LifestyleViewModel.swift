//
//  LifestyleViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import Foundation

class LifestyleViewModel: ObservableObject {
    @Published var questions: [Question] = [
        Question(
            text: "How do you like spending your free time?",
            options: [
                "Indoors", "Outdoors", "Alone", "In Small Groups",
                "In Large Groups", "Exploring New Places", "At Home Relaxing",
                "Trying New Activities", "Watching Shows or Movies", "Reading"
            ].map { QuestionOption(title: $0) }
        ),
        Question(
            text: "What’s your preferred group size for social activities?",
            options: [
                "1-on-1 Hangouts", "3-5 people",
                "6-10 people", "10+ people"
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