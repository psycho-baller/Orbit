//
//  MyMeetupRequestDetailScreen.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-18.
//

import SwiftUI

struct MyMeetupRequestDetailScreen: View {
    @Environment(\.colorScheme) var colorScheme
    let meetupRequest: MeetupRequestDocument
    //    let chats: [ChatModel]  // Represents approved responders

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Title Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(meetupRequest.data.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.text(for: colorScheme))

                    Text(meetupRequest.data.description)
                        .font(.body)
                        .foregroundColor(
                            ColorPalette.secondaryText(for: colorScheme))
                }
                .padding(.horizontal)

                // Meetup Info Section
                MeetupInfoSection(meetupRequest: meetupRequest)

                // Approved Responders Section (Chats)
                if let chats = meetupRequest.data.chats,
                    !chats.isEmpty
                {
                    MeetupApprovedRespondersSection(
                        chats: chats)
                }

                // Actions (Edit / Delete)
                HStack(spacing: 16) {
                    Button(action: {
                        // Handle Edit Meetup Request
                    }) {
                        Text("Edit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        // Handle Delete Meetup Request
                    }) {
                        Text("Delete")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Meetup Details")
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme

    MyMeetupRequestDetailScreen(
        meetupRequest: MeetupRequestDocument.mock()
    )
    .accentColor(ColorPalette.accent(for: colorScheme))
}
