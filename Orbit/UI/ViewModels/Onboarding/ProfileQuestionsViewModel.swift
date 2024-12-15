//
//  ProfileQuestionsViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-10-30.
//

import Foundation

class ProfileQuestionsViewModel: ObservableObject {
    @Published var questions: [Question] = []

    init() {
        loadQuestions(with: nil)
    }

    func loadQuestions(with currentUser: UserModel?) {
        questions = [
            Question(
                text: "What are some activities or hobbies that bring you joy?",
                options: [
                    "Hiking", "Reading", "Cooking", "Volunteering",
                    "Photography", "Yoga",
                    "Gaming", "Painting", "Sports", "Traveling", "Crafting",
                    "Coding",
                    "Music", "Meditation", "Dancing", "Gardening",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.profileQuestions?.contains(
                            title)
                            ?? false
                    )
                }
            ),
            Question(
                text: "Which conversation topics do you enjoy?",
                options: [
                    "Books", "Movies", "Science", "Philosophy", "Tech",
                    "Sports",
                    "Current Events", "Culture", "Food", "Travel", "Humour",
                    "Music",
                    "Personal Growth", "Enviroment", "Wellness",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.profileQuestions?.contains(
                            title)
                            ?? false
                    )
                }
            ),
            Question(
                text:
                    "What’s something you’d love to find a friend to do with you?",
                options: [
                    "Deep Conversations", "Workout", "Travel Buddy",
                    "Study Buddy", "Creative Collaborator", "Event Companion",
                    "Group Hangouts", "Casual Meetup",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.profileQuestions?.contains(
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
