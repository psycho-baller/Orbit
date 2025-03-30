//
//  NameAgePronounEditSheet.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-28.
//

#warning ("TODO: Make this look nicer. Take inspiration from the onboarding")

import SwiftUI

struct NameAgePronounEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var dateOfBirth: Date
    @State private var selectedPronouns: Set<UserPronouns> = []
    
    // For date picker only allow age between 16-100
    private let sixteenYearsAgo = Date().addingTimeInterval(-16 * 365 * 24 * 60 * 60)
    private let oneHundredYearsAgo = Date().addingTimeInterval(-100 * 365 * 24 * 60 * 60)
    
    // Pronouns options
    private let pronounsOptions: [UserPronouns] = [.heHim, .sheHer, .theyThem]
    
    init(user: UserModel) {
        self.user = user
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName ?? "")
        
        // Initialize date of birth
        if let dobString = user.dob, 
           let date = DateFormatterUtility.parseISODate(dobString) {
            _dateOfBirth = State(initialValue: date)
        } else {
            _dateOfBirth = State(initialValue: Date())
        }
        
        // Initialize pronouns
        _selectedPronouns = State(initialValue: Set(user.pronouns))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section(header: Text("Date of Birth")) {
                    DatePicker(
                        "Select your date of birth",
                        selection: $dateOfBirth,
                        in: oneHundredYearsAgo...sixteenYearsAgo,
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section(header: Text("Pronouns")) {
                    ForEach(pronounsOptions, id: \.self) { pronoun in
                        Button(action: {
                            if selectedPronouns.contains(pronoun) {
                                selectedPronouns.remove(pronoun)
                            } else {
                                selectedPronouns.insert(pronoun)
                            }
                        }) {
                            HStack {
                                Text(pronoun.rawValue)
                                    .foregroundColor(ColorPalette.text(for: colorScheme))
                                Spacer()
                                if selectedPronouns.contains(pronoun) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(ColorPalette.accent(for: colorScheme))
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Edit Personal Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Format date to ISO string
                        let isoDate = DateFormatterUtility.formatISO8601(dateOfBirth)
                        
                        // Update the view model with temporary changes
                        userVM.updateTempUserData(
                            firstName: firstName,
                            lastName: lastName.isEmpty ? nil : lastName,
                            dob: isoDate,
                            pronouns: Array(selectedPronouns)
                        )
                        
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NameAgePronounEditSheet(user: UserViewModel.mock().currentUser!)
        .environmentObject(UserViewModel.mock())
}

