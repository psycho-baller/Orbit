//
//  ApprovedMeetupScreen.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-17.
//


import SwiftUI

struct ApprovedMeetupScreen: View {
    let meetupRequest: MeetupRequestDocument

    var body: some View {
        VStack {
            Text("Approved Meetup")
                .font(.title)
                .padding()

            Text(meetupRequest.data.title)
                .font(.headline)
                .padding()
        }
    }
}

#Preview {
    ApprovedMeetupScreen(meetupRequest: MeetupRequestDocument.mock())
}