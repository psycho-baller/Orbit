//
//  SocialStyleViewModel.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-10-30.
//
import Foundation

class SocialStyleViewModel: ObservableObject {
    @Published var questions: [Question] = []

    init() {
        loadQuestions(with: nil)
    }

    func loadQuestions(with currentUser: UserModel?) {
        questions = [
            Question(
                text: "How would you describe your social style?",
                options: [
                    "Extroverted",
                    "Introverted",
                    "Outgoing",
                    "Reserved",
                    "Easygoing",
                    "Thoughtful",
                    "Adventurous",
                    "Laid-back",
                    "Highly energetic",
                    "Socially anxious",
                    "Spontaneous",
                    "Organized",
                    "Depends on the situation",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialStyle?.mySocialStyle
                            .contains(title)
                            ?? false
                    )
                }
            ),
            Question(
                text:
                    "How do you usually feel after spending time with friends?",
                options: [
                    "Energized",
                    "Relaxed",
                    "Reflective",
                    "Ready for Alone Time",
                    "Inspired",
                    "Cheerful",
                    "Motivated",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialStyle?.feelAfterMeetup?
                            .contains(title)
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
            questions[questionIndex].options.indices.forEach {
                questions[questionIndex].options[$0].isSelected = false
            }
            questions[questionIndex].options[optionIndex].isSelected = true
        }
    }

    func getSocialStyle() -> SocialStyleModel {
        return SocialStyleModel(
            mySocialStyle:
                questions
                .first(where: { $0.text.contains("describe your social style") }
                )?
                .options
                .filter { $0.isSelected }
                .map { $0.title } ?? [],
            feelAfterMeetup:
                questions
                .first(where: { $0.text.contains("feel after") })?
                .options.first(where: { $0.isSelected })?.title
        )
    }
}
