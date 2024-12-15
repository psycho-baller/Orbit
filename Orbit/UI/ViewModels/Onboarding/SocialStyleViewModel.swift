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
                    "Extroverted", "Introverted", "Outgoing", "Reserved",
                    "Easygoing",
                    "Thoughtful", "Adventurous", "Laid-back",
                    "Highly energetic",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialStyle?.contains(title)
                            ?? false
                    )
                }
            ),
            Question(
                text: "What’s your preferred group size for social activities?",
                options: [
                    "1-on-1 Hangouts", "Small Groups (3-5 people)",
                    "Medium Groups (6-10 people)",
                    "Large Gatherings (10+ people)",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialStyle?.contains(title)
                            ?? false
                    )
                }
            ),
            Question(
                text:
                    "How do you usually feel after spending time with friends?",
                options: [
                    "Energized", "Relaxed", "Reflective",
                    "Ready for Alone Time",
                    "Inspired", "Cheerful", "Motivated",
                ].map { title in
                    QuestionOption(
                        title: title,
                        isSelected: currentUser?.socialStyle?.contains(title)
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
}
