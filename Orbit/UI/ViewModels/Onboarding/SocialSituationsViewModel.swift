//
//  SocialSituationsViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import Foundation

class SocialSituationsViewModel: ObservableObject {
    @Published var questions: [Question] = []

    init() {
        loadQuestions(with: nil)
    }

    func loadQuestions(with currentUser: UserModel?) {
        questions = [
            Question(
                text: "When you meet new people, how do you usually feel?",
                options: [
                    "Excited", "Curious", "Nervous", "Neutral",
                    "Reserved", "Comfortable",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialSituations?.contains(
                            title)
                            ?? false
                    )
                }
            ),
            Question(
                text:
                    "If you’re at a social event, what role do you find yourself taking?",
                options: [
                    "The Planner", "The Social Butterfly", "The Listener",
                    "The Helper", "The Observer", "The Icebreaker",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialSituations?.contains(
                            title)
                            ?? false
                    )
                }
            ),
            Question(
                text: "How often would you like to connect with new people?",
                options: [
                    "Frequently", "Occasionally",
                    "Rarely", "No preference",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialSituations?.contains(
                            title)
                            ?? false
                    )
                }
            ),
        ]
    }
    func toggleSelection(for option: QuestionOption, in question: Question) {
        if let questionIndex = questions.firstIndex(where: {
            $0.id == question.id
        }),
            let optionIndex = questions[questionIndex].options.firstIndex(
                where: { $0.id == option.id })
        {
            questions[questionIndex].options[optionIndex].isSelected.toggle()
        }
    }
}
