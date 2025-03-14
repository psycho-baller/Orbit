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
                options: [
                    "Deep Conversations",
                    "Adventure",
                    "Humor",
                    "Loyalty",
                    "Honesty",
                    "Kindness",
                    "Respect",
                    "Similar Interests",
                    "Mutual Support",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.values?
                            .contains(
                                title)
                            ?? false
                    )
                }
            ),
            Question(
                text:
                    "What qualities do you look for in someone you’d like to meet?",
                options: [
                    "Good Listener",
                    "Outgoing",
                    "Empathetic",
                    "Reliable",
                    "Intelligent",
                    "Creative",
                    "Curious",
                    "Funny",
                    "Open-Minded",
                    "Positive",
                    "Thoughtful",
                    "Passionate",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.qualities?
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
            values:
                questions
                .first(where: { $0.text.contains("value most") })?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [],
            qualities:
                questions
                .first(where: { $0.text.contains("you’d like to meet") })?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [])

    }
}
