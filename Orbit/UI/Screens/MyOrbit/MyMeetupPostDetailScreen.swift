//
//  MyMeetupRequestDetailScreen.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-18.
//

import SwiftUI

struct MyMeetupPostDetailScreen: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var isEditing = false

    let meetupRequest: MeetupRequestDocument

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            ColorPalette.background(for: colorScheme)
                .ignoresSafeArea()

            // Scrollable content
            ScrollView {
                VStack(spacing: 16) {
                    MeetupInfoSection(meetupRequest: meetupRequest)

                    if let chats = meetupRequest.data.chats, !chats.isEmpty {
                        MeetupRespondersSection(chats: chats)
                    } else {
                        Text("No responders yet.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding()
                    }
                    Spacer().frame(height: 100)
                }
                .padding(.vertical)
            }

            // Floating buttons
            HStack(spacing: 16) {
                Button(action: {
                    isEditing = true
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
            .padding(.bottom, 24)
            .background(.clear)
        }
        .navigationTitle("Meetup Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditing) {
            EditMeetupPostSheet(meetupRequest: meetupRequest) {
                isEditing = false
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme
    MyMeetupPostDetailScreen(
        meetupRequest: MeetupRequestDocument.mock()
    )
    .accentColor(ColorPalette.accent(for: colorScheme))
}
