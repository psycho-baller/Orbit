//
//  NameAgePronounEditSheet.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-28.
//


import SwiftUI
import Loaf

struct NameAgePronounEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var dateOfBirth: Date
    @State private var selectedPronouns: Set<UserPronouns> = []
    @State private var showPronouns: Bool
    @State private var showGender: Bool
    @FocusState private var isFirstNameFocused: Bool
    @FocusState private var isLastNameFocused: Bool
    @State private var selectedGender: UserGender?
    @State private var isSaving = false
    
    // For date picker only allow age between 16-100
    private var sixteenYearsAgo: Date {
        Calendar.current.date(byAdding: .year, value: -16, to: Date()) ?? Date()
    }
    private var oneHundredYearsAgo: Date {
        Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
    }
    
    // Pronouns options
    private let pronounsOptions: [UserPronouns] = [.heHim, .sheHer, .theyThem]
    
    init(user: UserModel) {
        self.user = user
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName ?? "")
        
        // Initialize display preferences
        _showPronouns = State(initialValue: user.showPronouns)
        _showGender = State(initialValue: user.showGender)
        
        // Initialize date of birth
        if let dobString = user.dob {
            // Try parsing with all methods for compatibility
            if let date = DateFormatterUtility.parseDateOnly(dobString) {
                print("Successfully parsed DOB using parseDateOnly: \(dobString) -> \(date)")
                _dateOfBirth = State(initialValue: date)
            } else if let date = DateFormatterUtility.parseISO8601(dobString) {
                print("Successfully parsed DOB using parseISO8601: \(dobString) -> \(date)")
                _dateOfBirth = State(initialValue: date)
            } else if let date = DateFormatterUtility.parseISODate(dobString) {
                print("Successfully parsed DOB using parseISODate: \(dobString) -> \(date)")
                _dateOfBirth = State(initialValue: date)
            } else {
                print("Failed to parse DOB with all methods: \(dobString)")
                _dateOfBirth = State(initialValue: Date())
            }
        } else {
            print("No DOB string found in user model")
            _dateOfBirth = State(initialValue: Date())
        }
        
        // Initialize pronouns and gender
        _selectedPronouns = State(initialValue: Set(user.pronouns))
        _selectedGender = State(initialValue: user.gender)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Name Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What's your name?")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.text(for: colorScheme))
                        
                        VStack(spacing: 12) {
                            TextField("First Name", text: $firstName)
                                .padding()
                                .background(ColorPalette.lightGray(for: colorScheme))
                                .cornerRadius(10)
                                .focused($isFirstNameFocused)
                            
                            TextField("Last Name (Optional)", text: $lastName)
                                .padding()
                                .background(ColorPalette.lightGray(for: colorScheme))
                                .cornerRadius(10)
                                .focused($isLastNameFocused)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Date of Birth Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("When's your birthday?")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.text(for: colorScheme))
                        
                        Text("You must be at least 16 years old to use Orbit")
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        
                        DatePicker(
                            "Date of Birth",
                            selection: $dateOfBirth,
                            in: oneHundredYearsAgo...sixteenYearsAgo,
                            displayedComponents: .date
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorPalette.lightGray(for: colorScheme))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Gender Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What's your gender?")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.text(for: colorScheme))
                        
                        VStack(spacing: 12) {
                            ForEach(UserGender.allCases, id: \.self) { gender in
                                Button(action: {
                                    selectedGender = gender
                                }) {
                                    HStack {
                                        Text(gender.rawValue.capitalized)
                                            .font(.body)
                                            .foregroundColor(ColorPalette.text(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        // Fixed-size container for the checkmark/circle
                                        ZStack {
                                            if selectedGender == gender {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                                                    .font(.system(size: 20))
                                            } else {
                                                Circle()
                                                    .strokeBorder(ColorPalette.secondaryText(for: colorScheme), lineWidth: 1)
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        .frame(width: 24, height: 24)
                                    }
                                    .padding()
                                    .background(ColorPalette.lightGray(for: colorScheme))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Toggle(isOn: $showGender) {
                                Text("Display gender on profile")
                                    .font(.body)
                                    .foregroundColor(ColorPalette.text(for: colorScheme))
                            }
                            .padding()
                            .background(ColorPalette.lightGray(for: colorScheme))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Pronouns Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What are your pronouns?")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.text(for: colorScheme))
                        
                        Text("Select all that apply")
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        
                        VStack(spacing: 12) {
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
                                            .font(.body)
                                            .foregroundColor(ColorPalette.text(for: colorScheme))
                                        
                                        Spacer()
                                        
                                        // Fixed-size container for the checkmark/circle
                                        ZStack {
                                            if selectedPronouns.contains(pronoun) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                                                    .font(.system(size: 20))
                                            } else {
                                                Circle()
                                                    .strokeBorder(ColorPalette.secondaryText(for: colorScheme), lineWidth: 1)
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        .frame(width: 24, height: 24)
                                    }
                                    .padding()
                                    .background(ColorPalette.lightGray(for: colorScheme))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Pronouns display preference
                            Toggle(isOn: $showPronouns) {
                                Text("Display pronouns on profile")
                                    .font(.body)
                                    .foregroundColor(ColorPalette.text(for: colorScheme))
                            }
                            .padding()
                            .background(ColorPalette.lightGray(for: colorScheme))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
            .simultaneousGesture(
                DragGesture().onChanged({ _ in
                    // Dismiss keyboard when scrolling
                    isFirstNameFocused = false
                    isLastNameFocused = false
                })
            )
            .onTapGesture {
                // Dismiss keyboard when tapping anywhere in the scroll view
                isFirstNameFocused = false
                isLastNameFocused = false
            }
            .navigationTitle("Edit Personal Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if isFormValid {
                            isSaving = true
                            
                            // Format date to match the format used in onboarding
                            let formattedDate = DateFormatterUtility.formatDateOnly(dateOfBirth)
                            
                            // Capture all values to use in the background task
                            let firstNameToSave = firstName
                            let lastNameToSave = lastName.isEmpty ? nil : lastName
                            let pronounsToSave = Array(selectedPronouns)
                            let genderToSave = selectedGender
                            let showPronounsToSave = showPronouns
                            let showGenderToSave = showGender
                            
                            // Dismiss immediately for a snappier feel
                            dismiss()
                            
                            // Then perform the update in the background
                            Task {
                                await userVM.updateAndSaveUserData(
                                    firstName: firstNameToSave,
                                    lastName: lastNameToSave,
                                    dob: formattedDate,
                                    pronouns: pronounsToSave,
                                    gender: genderToSave,
                                    showPronouns: showPronounsToSave,
                                    showGender: showGenderToSave,
                                    sectionName: "Personal info"
                                )
                            }
                        }
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
            .background(ColorPalette.background(for: colorScheme))
        }
    }
    
    // Validation
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    NameAgePronounEditSheet(user: UserViewModel.mock().currentUser!)
        .environmentObject(UserViewModel.mock())
}

