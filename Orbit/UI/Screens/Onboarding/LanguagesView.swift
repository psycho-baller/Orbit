//
//  LanguagesView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-24.
//

import SwiftUI

struct LanguagesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var userVM: UserViewModel

    /// Use `@State` to store the search text.
    @State private var searchText: String = ""

    /// For controlling the bottom sheet.
    @State private var selectedLanguageForSheet: UserLanguageModel? = nil
    /// Manage the currently selected language for the bottom sheet.
    @State private var selectedLanguages: [UserLanguageModel] = []

    private var availableLanguages: [Language] =
        DataLoader.loadLanguagesFromJSON()
    /// Simple mapping of integer proficiency to a user-friendly label.
    private let proficiencyLevels: [(label: String, value: Int)] = [
        ("Interested", 0),
        ("Beginner", 1),
        ("Intermediate", 2),
        ("Advanced", 3),
        ("Fluent", 4),
        ("Native", 5),
    ]

    /// Filter the list based on the search text.
    private var filteredLanguages: [Language] {
        if searchText.isEmpty {
            return availableLanguages
        } else {
            // Match either name or autonym to the search text
            return availableLanguages.filter {
                ($0.name)
                    .localizedCaseInsensitiveContains(searchText)
                    || ($0.autonym)
                        .localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    public init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section(
                header: Text(
                    "What are some languages you speak or are interested in learning?"
                )
            ) {
                ForEach(filteredLanguages) { language in
                    // You can use a Button or NavigationLink here;
                    // a Button is convenient if you are using a .sheet.
                    Button {
                        selectedLanguageForSheet = UserLanguageModel(
                            languageId: language.languageId, proficiency: 0)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(language.name)
                                    .font(.body)
                                Text(language.autonym)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            // Show the current proficiency as a label
                            // until the user picks a new one.
                            //                            if let currentLabel = proficiencyLevels.first(
                            //                                where: { $0.value == language.proficiency })
                            //                            {
                            //                                Text(currentLabel.label)
                            //                                    .foregroundColor(.blue)
                            //                            } else {
                            //                                Text("Select")
                            //                                    .foregroundColor(.blue)
                            //                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)  // iOS 15+
        .navigationTitle("Languages")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    viewModel.navigationPath.append(
                        OnboardingViewModel.OnboardingStep.genderPronouns)
                    // Save all chosen languages into the user’s data.
                    Task {
                        await userVM.saveOnboardingData(
                            userLanguages: selectedLanguages
                        )
                    }
                }
            }
        }
        // Presents a "bottom sheet" to pick proficiency once a language is selected.
        .sheet(item: $selectedLanguageForSheet) { lang in
            ProficiencyPickerSheet(
                language: lang,
                proficiencyLevels: proficiencyLevels,
                onProficiencySelected: { updatedLanguage in
                    // Either add or update the chosen language in selectedLanguages
                    if let idx = selectedLanguages.firstIndex(where: {
                        $0.id == updatedLanguage.id
                    }) {
                        // Update existing entry
                        //                        selectedLanguages[idx].proficiency =
                        //                            updatedLanguage.proficiency
                    } else {
                        // Append as new entry
                        selectedLanguages.append(updatedLanguage)
                    }
                }
            )
        }
    }
}

/// The bottom sheet that shows proficiency levels 0-5.
/// Once the user picks a level, we call `onProficiencySelected`.
struct ProficiencyPickerSheet: View {
    @Environment(\.presentationMode) private var presentationMode

    let language: UserLanguageModel
    let proficiencyLevels: [(label: String, value: Int)]

    var onProficiencySelected: (UserLanguageModel) -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select Proficiency")) {
                    //                    ForEach(proficiencyLevels, id: \.value) { level in
                    //                        Button {
                    //                            let updated = UserLanguageModel(
                    //                                languageId: language.languageId,
                    //                                proficiency: level.value,
                    //                                name: language.name,
                    //                                autonym: language.autonym
                    //                            )
                    //                            onProficiencySelected(updated)
                    //                            presentationMode.wrappedValue.dismiss()
                    //                        } label: {
                    //                            HStack {
                    //                                Text(level.label)
                    //                                Spacer()
                    //                                if language.proficiency == level.value {
                    //                                    Image(systemName: "checkmark")
                    //                                        .foregroundColor(.accentColor)
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                }
            }
            .navigationTitle(language.languageId)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        LanguagesView(viewModel: OnboardingViewModel())
            .environmentObject(UserViewModel.mock())
    }
#endif
