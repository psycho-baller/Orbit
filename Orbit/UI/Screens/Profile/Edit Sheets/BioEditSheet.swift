//
//  BioEditSheet.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-29.
//

#warning ("TODO: Make it look nicer, Match the onboarding")

import SwiftUI

struct BioEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    
    @State private var bio: String
    @State private var isSaving = false
    
    // Maximum word count for bio
    private let maxWordCount = 50
    
    // Calculate current word count
    private var wordCount: Int {
        bio.split(separator: " ").count
    }
    
    private var isValidBio: Bool {
        wordCount <= maxWordCount
    }
    
    init(user: UserModel) {
        self.user = user
        _bio = State(initialValue: user.bio ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("In 50 words or less, how would you describe yourself?")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        .padding(.horizontal)
                    
                    // Bio text editor - using TextField to match onboarding
                    TextField("", text: $bio, axis: .vertical)
                        .padding()
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                        .background(ColorPalette.lightGray(for: colorScheme))
                        .cornerRadius(10)
                        .frame(minHeight: 150)
                        .padding(.horizontal)
                    
                    // Word count indicator - matching onboarding style
                    HStack {
                        Spacer()
                        Text("^[\(wordCount) word](inflect: true)")
                            .font(.caption)
                            .foregroundColor(
                                isValidBio ?
                                ColorPalette.secondaryText(for: colorScheme) :
                                .red
                            )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationBarTitle("Edit Bio", displayMode: .inline)
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
                        if isValidBio {
                            isSaving = true
                            
                            Task {
                                await userVM.updateAndSaveUserData(bio: bio.isEmpty ? nil : bio)
                                dismiss()
                            }
                        }
                    }
                    .disabled(!isValidBio || isSaving)
                }
            }
            .background(ColorPalette.background(for: colorScheme))
        }
    }
}

#Preview {
    BioEditSheet(user: UserViewModel.mock().currentUser!)
        .environmentObject(UserViewModel.mock())
}

