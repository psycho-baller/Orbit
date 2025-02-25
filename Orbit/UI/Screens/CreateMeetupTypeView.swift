//
//  CreateMeetupTypeView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-02-24.
//

import SwiftUI

struct CreateMeetupTypeView: View {
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedType: MeetupType? = nil
    @State private var showingDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("What would you like to do?")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Meetup Type Buttons
                            VStack(spacing: 12) {
                                MeetupTypeButton(
                                    title: "Get Coffee",
                                    icon: "cup.and.saucer.fill",
                                    isSelected: selectedType == .coffee
                                ) {
                                    selectedType = .coffee
                                }
                                
                                MeetupTypeButton(
                                    title: "Have a meal",
                                    icon: "fork.knife",
                                    isSelected: selectedType == .meal
                                ) {
                                    selectedType = .meal
                                }
                                
                                MeetupTypeButton(
                                    title: "Sports/Workout",
                                    icon: "figure.run",
                                    isSelected: selectedType == .indoorActivity
                                ) {
                                    selectedType = .indoorActivity
                                }
                                
                                MeetupTypeButton(
                                    title: "Outdoor activity",
                                    icon: "figure.hiking",
                                    isSelected: selectedType == .outdoorActivity
                                ) {
                                    selectedType = .outdoorActivity
                                }
                                
                                MeetupTypeButton(
                                    title: "Other",
                                    icon: "ellipsis.circle.fill",
                                    isSelected: selectedType == .other
                                ) {
                                    selectedType = .other
                                }
                            }
                        }
                        .padding()
                    }
                    
                    VStack {
                        Button(action: {
                            if selectedType != nil {
                                showingDetails = true
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    selectedType != nil 
                                        ? ColorPalette.accent(for: colorScheme)
                                        : ColorPalette.lightGray(for: colorScheme)
                                )
                                .cornerRadius(12)
                        }
                        .disabled(selectedType == nil)
                        .padding()
                    }
                    .background(ColorPalette.background(for: colorScheme))
                }
            }
            .navigationDestination(isPresented: $showingDetails) {
                if let type = selectedType {
                    CreateMeetupDetailsView(selectedType: type)
                }
            }
        }
    }
    
    private func canProceed() -> Bool {
        selectedType != nil
    }
}

struct MeetupTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.body)
                Spacer()
            }
            .foregroundColor(isSelected ? .white : ColorPalette.text(for: .light))
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : ColorPalette.main(for: .light))
            .cornerRadius(12)
        }
    }
}

#if DEBUG
struct CreateMeetupTypeView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMeetupTypeView()
            .environmentObject(MeetupRequestViewModel.mock())
            .environmentObject(UserViewModel.mock())
    }
}
#endif
