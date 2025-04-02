//
//  FriendshipValuesViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import Foundation

class FriendshipValuesViewModel: ObservableObject {
    @Published var questions: [Question] = []

    init() {
        loadQuestions(with: nil)
    }

    func loadQuestions(with currentUser: UserModel?) {
        questions = [
            Question(
                text: "What do you value most in a friendship?",
                options: OnboardingOptions.friendshipValues.map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.friendshipValues?
                            .contains(
                                title)
                            ?? false
                    )
                }
            ),
            Question(
                text:
                    "What qualities do you look for in someone you'd like to meet?",
                options: OnboardingOptions.friendshipQualities.map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.friendshipQualities?
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

    func getFriendshipValues() -> FriendshipValuesModel {
        return FriendshipValuesModel(
            friendshipValues:
                questions
                .first(where: { $0.text.contains("value most") })?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [],
            friendshipQualities:
                questions
                .first(where: { $0.text.contains("you’d like to meet") })?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [])

    }
}
