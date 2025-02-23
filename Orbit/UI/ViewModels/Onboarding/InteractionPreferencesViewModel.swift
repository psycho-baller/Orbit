//
//  InteractionPreferencesViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import Foundation

class InteractionPreferencesViewModel: ObservableObject {
    @Published var questions: [Question] = []

    init() {
        loadQuestions(with: nil)
    }

    func loadQuestions(with currentUser: UserModel?) {
        questions = [
            Question(
                text:
                    "Which activities would you enjoy doing with other Astronauts?",
                options: [
                    "Grab a coffee together",
                    "Share a meal",
                    "Enjoy hobbies together",
                    "Try an outdoor adventure",
                    "Play or participate in sports activities",
                    "Practice speaking a new language"
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.interactionPreferences?
                            .events?.contains(title)
                            ?? false
                    )
                }
            ),
            Question(
                text: "Which conversation topics do you enjoy?",
                options: [
                    "Books",
                    "Movies",
                    "Tech",
                    "Philosophy",
                    "Psychology",
                    "Wellness",
                    "Personal Growth",
                    "Sports",
                    "Fitness",
                    "Relationships",
                    "Spirituality",
                    "Health",
                    "Current Events",
                    "Culture",
                    "Food",
                    "Travel",
                    "Music",
                    "Art",
                    "Fashion",
                    "Gaming",
                    "Nature",
                    "Animals",
                    "Career",
                    "Education",
                    "Politics",
                    "Social Issues",
                    "Entrepreneurship",
                    "History",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.interactionPreferences?
                            .topics?.contains(title)
                            ?? false
                    )
                }
            ),
        ]
    }

    // Function to toggle the selection state of a particular option within a question
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

    func getInteractionPreferences() -> InteractionPreferencesModel {
        return InteractionPreferencesModel(
            events:
                questions
                .first(where: { $0.text.contains("Which activities") })?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [],
            topics:
                questions
                .first(where: { $0.text.contains("Which conversation topics") }
                )?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [])
    }
}
