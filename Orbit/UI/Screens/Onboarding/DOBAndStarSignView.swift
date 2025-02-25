import SwiftUI

struct DOBAndStarSignView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var userVM: UserViewModel

    @State private var dateOfBirth: Date = Date()
    @State private var shareStarSign: Bool = true
    
    var body: some View {
        Form {
            Section(header: Text("What is your date of birth?")) {
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            Section(header: Text("Would you like to share your star sign?")) {
                Toggle("Share my star sign", isOn: $shareStarSign)
            }
        }
        .navigationTitle("Birthday")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task {
                        await userVM.saveOnboardingData(dob: dateOfBirth)
                        // Optionally update the star sign preference here.
                        userVM.currentUser?.showStarSign = shareStarSign
                    }
                    viewModel.navigationPath.append(.userLinks)
                }
            }
        }
    }
}