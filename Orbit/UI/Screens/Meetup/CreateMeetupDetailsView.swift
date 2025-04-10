//
//  CreateMeetupDetailsView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-02-24.
//
import SwiftUI

struct CreateMeetupDetailsView: View {
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    let selectedType: MeetupType

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startTime = Date()
    @State private var selectedIntention: MeetupIntention = .friendship
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedLocation: String = ""
    @State private var locationSearchText: String = ""
    @State private var isShowingLocationDropdown = false
    @State private var selectedLocationId: String?
    @State private var locations: [Area] = []
    @State private var genderPreference: GenderPreference = .any

    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty
    }

    var body: some View {
        ZStack {
            ColorPalette.background(for: colorScheme)
                .ignoresSafeArea()
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
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

                        // Location Selection
                        VStack(alignment: .leading) {
                            LocationPickerView(
                                locationSearchText: $locationSearchText,
                                selectedLocation: $selectedLocation,
                                selectedLocationId: $selectedLocationId,
                                isShowingLocationDropdown:
                                    $isShowingLocationDropdown,
                                locations: locations,
                                colorScheme: colorScheme
                            )
                        }

                        // Intention Selection
                        VStack(alignment: .leading) {
                            Text("Meetup Intention")
                                .font(.headline)
                            Picker("", selection: $selectedIntention) {
                                Text("Friendship").tag(
                                    MeetupIntention.friendship)
                                Text("Relationship").tag(
                                    MeetupIntention.relationship)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(ColorPalette.main(for: colorScheme))
                            .cornerRadius(12)
                        }

                        // New Target Gender Section
                        VStack(alignment: .leading) {
                            Text("Gender Preferences")
                                .font(.headline)
                            Picker("", selection: $genderPreference) {
                                ForEach(GenderPreference.allCases) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
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
                    }
                    .padding()
                }
                #warning(
                    "TODO: Make submit create a meetup -> show user a success screen -> then redirect back to home"
                )
                VStack {
                    Button(action: createMeetup) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                isFormValid
                                    ? ColorPalette.accent(for: colorScheme)
                                    : ColorPalette.lightGray(for: colorScheme)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding()
                }
                .background(ColorPalette.background(for: colorScheme))
            }
        }
        .onAppear {
            loadLocations()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
    }

    private func createMeetup() {
        guard let currentUser = userVM.currentUser else {
            alertMessage = "User not found"
            showingAlert = true
            return
        }

        let startTimeString: String = DateFormatterUtility.formatISO8601(
            startTime)
        let endTime =
            Calendar.current.date(byAdding: .hour, value: 1, to: startTime)
            ?? startTime.addingTimeInterval(3600)
        let endTimeString = DateFormatterUtility.formatISO8601(endTime)

        print("Debug - Creating meetup:")
        print("Start time: \(startTimeString)")
        print("End time: \(endTimeString)")
        print("Current user: \(currentUser)")

        Task {
            await meetupRequestVM.createMeetup(
                title: title,
                startTime: startTimeString,
                endTime: endTimeString,
                areaId: Int(selectedLocationId ?? "521659157") ?? 521_659_157,
                description: description,
                status: .active,
                intention: selectedIntention,
                createdByUser: currentUser,
                type: selectedType,
                genderPreference: genderPreference
            )
            dismiss()
        }
    }

    private func loadLocations() {
        locations = DataLoader.loadUofCLocationDataFromJSON()
            .filter { $0.categories.contains("building.university") }
    }
}

#if DEBUG
    struct CreateMeetupDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            CreateMeetupDetailsView(selectedType: .coffee)
                .environmentObject(MeetupRequestViewModel.mock())
                .environmentObject(UserViewModel.mock())
        }
    }
#endif
