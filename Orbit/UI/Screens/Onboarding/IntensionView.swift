import SwiftUI

struct IntensionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    // All possible intensions from your enum
    @State private var availableIntensions: [String] = UserIntention.allCases.map { $0.rawValue }
    // Basket items (user’s ordered priorities)
    @State private var selectedIntensions: [String] = []
    
    var body: some View {
        VStack {
            DragAndDropScreen(
                title: "What brings you to Orbit?",
                description: "Drag and drop to sort your priorities.",
                availableItems: $availableIntensions,
                basketItems: $selectedIntensions
            )
            Spacer()
            Button("Next") {
                let intensions = selectedIntensions.compactMap { rawValue in
                    UserIntention(rawValue: rawValue)
                }
                viewModel.userModel.intension = intensions
                viewModel.navigationPath.append(OnboardingViewModel.OnboardingStep.personalPreferences)
            }
            .padding()
        }
        .navigationTitle("Intention")
    }
}