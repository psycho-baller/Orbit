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
                    "Excited and Energized",
                    "Curious",
                    "Nervous",
                    "Neutral",
                    "Reserved but Interested",
                    "Comfortable",
                    "It depends on the situation",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialSituations?
                            .feelWhenMeetingNewPeople?.contains(
                                title)
                            ?? false
                    )
                }
            ),
            Question(
                text:
                    "If you’re at a social event, what role do you find yourself taking?",
                options: [
                    "The Planner",
                    "The Social Butterfly",
                    "The Listener",
                    "The Helper",
                    "The Observer",
                    "The Icebreaker",
                    "I adapt to the situation",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialSituations?.socialRole?
                            .contains(
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

    func getSocialSituations() -> SocialSituationsModel {
        return SocialSituationsModel(
            feelWhenMeetingNewPeople:
                questions
                .first(where: {
                    $0.text.contains("feel")
                })?
                .options.first(where: { $0.isSelected })?.title,
            socialRole:
                questions
                .first(where: { $0.text.contains("social") })?
                .options.first(where: { $0.isSelected })?.title
        )
    }
}
