//
//  LifestyleView.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//

import SwiftUI

struct LifestyleView: View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject private var viewModel = LifestyleViewModel()
    @State private var showHomeScreen = false  // State to navigate to next screen
    
    // Define the grid layout for three columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Lifestyle & Free Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Loop through each question
                ForEach(viewModel.questions) { question in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(question.text)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Use LazyVGrid for a multi-column layout with three columns
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(question.options) { option in
                                Text(option.title)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(option.isSelected ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(option.isSelected ? .white : .primary)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        viewModel.toggleSelection(for: option, in: question)
                                    }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Navigation button to the next screen
                Button(action: {
                    let selectedAnswers = viewModel.questions.flatMap { question in
                        question.options.filter { $0.isSelected }.map { $0.title }
                    }

                    Task {
                        await userVM.saveOnboardingData(
                            profileQuestions: nil,  // Already handled in previous screens
                            socialStyle: nil,       // Already handled in previous screens
                            interactionPreferences: nil,  // Already handled in previous screens
                            friendshipValues: nil,  // Already handled in previous screens
                            socialSituations: nil,  // Already handled in previous screens
                            lifestylePreferences: selectedAnswers  // Final screen data
                        )

                        // Mark onboarding as complete
                        userVM.currentUser?.hasCompletedOnboarding = true  // Update locally
                        await userVM.saveOnboardingData(
                            profileQuestions: userVM.currentUser?.profileQuestions,
                            socialStyle: userVM.currentUser?.socialStyle,
                            interactionPreferences: userVM.currentUser?.interactionPreferences,
                            friendshipValues: userVM.currentUser?.friendshipValues,
                            socialSituations: userVM.currentUser?.socialSituations,
                            lifestylePreferences: userVM.currentUser?.lifestylePreferences
                        )
                    }

                    showHomeScreen = true
                }) {
                    Text("Finish")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }


                .background(
                    NavigationLink(
                        destination: HomeView()
                            .environmentObject(userVM),  // Pass UserViewModel
                        isActive: $showHomeScreen
                    ) {
                        EmptyView()
                    }
                )

                
            }
        }
    }
}


struct LifestyleView_Previews: PreviewProvider {
    static var previews: some View {
        LifestyleView()
    }
}

