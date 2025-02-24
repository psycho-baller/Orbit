//
//  CreateMeetupView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-02-21.
//

import SwiftUI

struct CreateMeetupView: View {
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startTime = Date()
    @State private var selectedType: MeetupType = .coffee
    @State private var selectedIntention: MeetupIntension = .friendship
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedLocation: String = ""
    @State private var locationSearchText: String = ""
    @State private var isShowingLocationDropdown = false
    
    #warning(
        "TODO: Make locations work and add search bar for it"
    )
//    private var locations: [Area] {
//        DataLoader.loadUofCLocationDataFromJSON()
//    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                
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
                        
                        // Title Field
                        VStack(alignment: .leading) {
                            Text("Title")
                                .font(.headline)
                            TextField("Conversation starter...", text: $title)
                                .padding()
                                .background(ColorPalette.main(for: colorScheme))
                                .cornerRadius(12)
                        }
                        
                        
                        // Date & Time
                        VStack(alignment: .leading) {
                            Text("Date & Time")
                                .font(.headline)
                            DatePicker("", selection: $startTime, in: Date()...)
                                .datePickerStyle(.compact)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(ColorPalette.main(for: colorScheme))
                                .cornerRadius(12)
                        }
                        
                        // Intention Selection
                        VStack(alignment: .leading) {
                            Text("Meetup Intention")
                                .font(.headline)
                            Picker("", selection: $selectedIntention) {
                                Text("Friendship").tag(MeetupIntension.friendship)
                                Text("Relationship").tag(MeetupIntension.dating)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(ColorPalette.main(for: colorScheme))
                            .cornerRadius(12)
                        }
                        
                        // Description Field
                        VStack(alignment: .leading) {
                            Text("Description (more info)")
                                .font(.headline)
                            TextEditor(text: $description)
                                .scrollContentBackground(.hidden)
                                .padding()
                                .background(ColorPalette.main(for: colorScheme))
                                .cornerRadius(12)
                                .frame(height: 100)
                        }
                        
                        #warning(
                            "TODO: Make the submit button work"
                        )
                        Button(action: createMeetup) {
                            Text("Submit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorPalette.accent(for: colorScheme))
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func createMeetup() {
        guard let currentUser = userVM.currentUser else {
            alertMessage = "User not found"
            showingAlert = true
            return
        }
        
        Task {
            await meetupRequestVM.createMeetup(
                title: title,
                startTime: startTime,
                endTime: startTime.addingTimeInterval(3600),
                areaId: 1,
                description: description,
                status: .active,
                intension: selectedIntention,
                createdBy: currentUser,
                meetupApprovals: [],
                type: selectedType
            )
            dismiss()
        }
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
struct CreateMeetupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMeetupView()
            .environmentObject(MeetupRequestViewModel.mock())
            .environmentObject(UserViewModel.mock())
    }
}
#endif
