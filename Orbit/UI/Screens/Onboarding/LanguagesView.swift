import SwiftUI

struct LanguagesView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    // In a real app you’d fetch or define the available languages.
    @State private var availableLanguages: [UserLanguageModel] = [
        UserLanguageModel(languageId: "eng", name: "English", autonym: "English"),
        UserLanguageModel(languageId: "spa", name: "Spanish", autonym: "Spanish")
    ]
    
    var body: some View {
        Form {
            Section(header: Text("What are some languages you speak or are interested in learning?")) {
                ForEach(availableLanguages) { language in
                    HStack {
                        Text(language.name)
                        Spacer()
                        // Here you could add a selection indicator
                    }
                }
            }
        }
        .navigationTitle("Languages")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    // For simplicity, we assign all available languages.
                    // In a real app, you’d let the user choose.
                    viewModel.userModel.userLanguages = availableLanguages
                    viewModel.navigationPath.append(OnboardingViewModel.OnboardingStep.genderPronouns)
                }
            }
        }
    }
}