//
//  InteractionPreferencesViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import Foundation

class InteractionPreferencesViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var preferredMinAge: Int?
    @Published var preferredMaxAge: Int?
    @Published var preferredGender: [UserGender] = []

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
                    "Practice speaking a new language",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.preferredMeetupType?.contains(title)
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
                        isSelected: currentUser?
                            .convoTopics?.contains(title)
                            ?? false
                    )
                }
            ),
            //            Question(
            //                text: "What is your preferred age range for interactions?",
            //                options: (16...60).map { age in
            //                    QuestionOption(
            //                        title: "\(age)",
            //                        isSelected: (age
            //                            == currentUser?.interactionPreferences?
            //                            .preferredMinAge
            //                            || age
            //                                == currentUser?.interactionPreferences?
            //                                .preferredMaxAge)
            //                    )
            //                }
            //            ),
            //            Question(
            //                text: "What is your preferred gender for interactions?",
            //                options: UserGender.allCases.map { gender in
            //                    QuestionOption(
            //                        title: gender.rawValue.capitalized,
            //                        isSelected: currentUser?.interactionPreferences?
            //                            .preferredGender?.contains(where: {
            //                                $0.rawValue == gender.rawValue
            //                            }) ?? false
            //                    )
            //                }
            //            ),
        ]

        // Initialize age and gender values
        preferredMinAge = currentUser?.preferredMinAge
        preferredMaxAge = currentUser?.preferredMaxAge
        preferredGender =
            currentUser?.preferredGender
            ?? []
    }

    // Function to toggle the selection state of a particular option within a question
    func toggleSelection(for option: QuestionOption, in question: Question) {
        if let questionIndex = questions.firstIndex(where: {
            $0.id == question.id
        }),
            let optionIndex = questions[questionIndex].options.firstIndex(
                where: { $0.id == option.id })
        {
            let optionTitle = questions[questionIndex].options[optionIndex]
                .title

            if question.text.contains("preferred age range") {
                if let age = Int(optionTitle) {
                    if preferredMinAge == nil {
                        preferredMinAge = age
                    } else if preferredMaxAge == nil {
                        preferredMaxAge = age
                    } else {
                        preferredMinAge = age
                        preferredMaxAge = nil
                    }
                }
            } else if question.text.contains("preferred gender") {
                if let gender = UserGender(rawValue: optionTitle.lowercased()) {
                    if preferredGender.contains(gender) {
                        preferredGender.removeAll { $0 == gender }
                    } else {
                        preferredGender.append(gender)
                    }
                }
            } else {
                questions[questionIndex].options[optionIndex].isSelected
                    .toggle()
            }
        }
    }

    func getInteractionPreferences() -> InteractionPreferencesModel {
        return InteractionPreferencesModel(
            preferredMeetupType:
                questions
                .first(where: { $0.text.contains("Which activities") })?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [],
            convoTopics:
                questions
                .first(where: { $0.text.contains("Which conversation topics") }
                )?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [],
            preferredMinAge: preferredMinAge,
            preferredMaxAge: preferredMaxAge,
            preferredGender: preferredGender
        )
    }
}
