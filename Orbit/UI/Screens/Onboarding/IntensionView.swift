//
//  intentionView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-24.
//

import SwiftUI

struct IntentionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme  // Detect system color scheme

    // All possible intentions from your enum
    @State private var availableintentions: [String] = UserIntention.allCases
        .map { $0.description }
    // Basket items (user’s ordered priorities)
    @State private var selectedintentions: [UserIntention] = []
    private var selectedintentionsString: Binding<[String]> {
        Binding<[String]>(
            get: { selectedintentions.map { $0.description } },
            set: { newValues in
                selectedintentions = newValues.compactMap {
                    UserIntention(description: $0)
                }
            }
        )
    }
    var body: some View {
        ZStack {
            ScrollView {
                DragAndDropScreen(
                    title: "What brings you to Orbit?",
                    description: "Drag and drop to sort your priorities.",
                    availableItems: $availableintentions,
                    basketItems: selectedintentionsString
                )
                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 120)

                //            .background(ColorPalette.background(for: colorScheme))
            }
            .ignoresSafeArea(edges: [.bottom])
            .background(ColorPalette.background(for: colorScheme))  // Add background color to footer

            // Always visible footer button
            VStack {
                Spacer()

                Button(action: {
                    viewModel.navigationPath.append(
                        OnboardingViewModel.OnboardingStep
                            .personalPreferences)

                    Task {
                        await userVM.saveOnboardingData(
                            intentions: selectedintentions
                        )
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            canProceed()
                                ? ColorPalette.accent(for: colorScheme)
                                : ColorPalette.accent(for: colorScheme)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!canProceed())
                .padding(.horizontal)
                //                .padding(.bottom, -10)
            }
        }
        //        .navigationTitle("What brings you to Orbit?")
        //        .toolbar {
        //            ToolbarItem(placement: .principal) {
        //                Text("Your Custom Title")
        //                    .font(.system(size: 24, weight: .bold))
        //            }
        //        }
        .background(ColorPalette.background(for: colorScheme))
        .onAppear {
            if let userIntentions = userVM.currentUser?.intentions {
                selectedintentions = userIntentions.compactMap {
                    print(
                        "$0.rawValue: \($0.rawValue), \(String(describing: UserIntention(rawValue: $0.rawValue)))"
                    )
                    return UserIntention(rawValue: $0.rawValue)
                }
                // remove these intentions from the available list
                availableintentions.removeAll {
                    selectedintentions.map { $0.description }.contains($0)
                }

            }
        }
    }

    //    canProceed
    //    }
    func canProceed() -> Bool {
        return !selectedintentionsString.isEmpty
    }
}

#if DEBUG
    #Preview {
        NavigationView {
            IntentionView(viewModel: .init())
                .environmentObject(UserViewModel.mock())
        }
        .navigationBarTitleDisplayMode(.inline)

    }
#endif
