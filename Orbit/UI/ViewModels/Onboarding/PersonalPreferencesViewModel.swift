//
//  PersonalPreferencesViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-10-30.
//

import Foundation

class PersonalPreferencesViewModel: ObservableObject {
    @Published var questions: [Question] = []

    init() {
        loadQuestions(with: nil)
    }

    func loadQuestions(with currentUser: UserModel?) {
        questions = [
            Question(
                text: "What are some activities or hobbies that bring you joy?",
                options: [
                    "Hiking",
                    "Reading",
                    "Cooking",
                    "Volunteering",
                    "Photography",
                    "Yoga",
                    "Gaming",
                    "Painting",
                    "Sports",
                    "Traveling",
                    "Crafting",
                    "Coding",
                    "Music",
                    "Meditation",
                    "Dancing",
                    "Gardening",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.personalPreferences?
                            .activitiesHobbies.contains(
                                title)
                            ?? false
                    )
                }
            ),
            Question(
                text:
                    "What’s something you’d love to find a friend to do with you?",
                options: [
                    "Workout Partner",
                    "Travel Buddy",
                    "Study Partner",
                    "Creative Collaborator",
                    "Hobby Buddy",
                    "Event Companion",
                    "Group Hangouts",
                    "Casual Meetup",
                    "Deep Conversations",
                    "Reliability Partner",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.personalPreferences?
                            .friendActivities.contains(
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

    func getPersonalPreferences() -> PersonalPreferences {
        let activitiesHobbies =
            questions
            .first(where: { $0.text.contains("activities or hobbies") })?
            .options
            .filter { $0.isSelected }
            .map { $0.title } ?? []

        let friendActivities =
            questions
            .first(where: { $0.text.contains("find a friend to do with you") })?
            .options
            .filter { $0.isSelected }
            .map { $0.title } ?? []

        return PersonalPreferences(
            activitiesHobbies: activitiesHobbies,
            friendActivities: friendActivities
        )
    }
}
