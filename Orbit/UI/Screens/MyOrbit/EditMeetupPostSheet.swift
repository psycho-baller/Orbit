//
//  EditMeetupPostSheet.swift
//  Orbit
//
//  Created by Jin Song on 2025-03-21.
//
import SwiftUI

struct EditMeetupPostSheet: View {
    let meetupRequest: MeetupRequestDocument
    var onDismiss: () -> Void

    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var title: String
    @State private var description: String
    @State private var startTime: Date
    @State private var selectedIntention: MeetupIntention
    @State private var selectedLocation: String = ""
    @State private var locationSearchText: String = ""
    @State private var isShowingLocationDropdown = false
    @State private var selectedLocationId: String?
    @State private var locations: [Area] = []

    init(meetupRequest: MeetupRequestDocument, onDismiss: @escaping () -> Void)
    {
        self.meetupRequest = meetupRequest
        self.onDismiss = onDismiss
        _title = State(initialValue: meetupRequest.data.title ?? "")
        _description = State(initialValue: meetupRequest.data.description ?? "")
        _startTime = State(
            initialValue: meetupRequest.data.startTimeDate ?? Date())
        _selectedIntention = State(
            initialValue: meetupRequest.data.intention ?? .friendship)
        _selectedLocationId = State(
            initialValue: String(meetupRequest.data.areaId))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // Title
                    SectionHeader("Title", colorScheme: colorScheme)
                    TextField("Enter title...", text: $title)
                        .padding()
                        .background(ColorPalette.main(for: colorScheme))
                        .cornerRadius(12)

                    // Date & Time
                    SectionHeader("Date & Time", colorScheme: colorScheme)
                    DatePicker("", selection: $startTime, in: Date()...)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(ColorPalette.main(for: colorScheme))
                        .cornerRadius(12)

                    // Location
                    LocationPickerView(
                        locationSearchText: $locationSearchText,
                        selectedLocation: $selectedLocation,
                        selectedLocationId: $selectedLocationId,
                        isShowingLocationDropdown: $isShowingLocationDropdown,
                        locations: locations,
                        colorScheme: colorScheme
                    )

                    // Intention
                    SectionHeader("Meetup Intention", colorScheme: colorScheme)
                    Picker("", selection: $selectedIntention) {
                        Text("Friendship").tag(MeetupIntention.friendship)
                        Text("Relationship").tag(MeetupIntention.relationship)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(ColorPalette.main(for: colorScheme))
                    .cornerRadius(12)

                    // Description
                    SectionHeader("Description", colorScheme: colorScheme)
                    TextEditor(text: $description)
                        .scrollContentBackground(.hidden)
                        .padding()
                        .background(ColorPalette.main(for: colorScheme))
                        .cornerRadius(12)
                        .frame(height: 100)
                }
                .padding()
            }
            .background(ColorPalette.background(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit Meetup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                }
            }
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
        .onAppear {
            locations = DataLoader.loadUofCLocationDataFromJSON()
                .filter { category in
                    category.categories.contains(where: {
                        $0.hasPrefix("building")
                    })
                }
        }
    }

    private func saveChanges() {
        /*
        Task {
            await meetupRequestVM.updateMeetup(
                id: meetupRequest.id,
                title: title,
                startTime: updatedStartTime,
                endTime: updatedEndTime,
                areaId: Int(selectedLocationId ?? "\(meetupRequest.data.areaId)") ?? meetupRequest.data.areaId,
                description: description,
                intention: selectedIntention
            )
            onDismiss()
        }
         */
    }
}

@ViewBuilder
func SectionHeader(_ text: String, colorScheme: ColorScheme) -> some View {
    Text(text)
        .font(.headline)
        .foregroundColor(ColorPalette.text(for: colorScheme))
        .frame(maxWidth: .infinity, alignment: .leading)
}
