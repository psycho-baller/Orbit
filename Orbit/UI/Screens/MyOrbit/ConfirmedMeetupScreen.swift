//
//  ConfirmedMeetupScreen.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-17.
//


import SwiftUI

struct ConfirmedMeetupScreen: View {
    let meetupRequest: MeetupRequestDocument

    var body: some View {
        VStack {
            Text("Confirmed Meetup")
                .font(.title)
                .padding()

            Text(meetupRequest.data.title)
                .font(.headline)
                .padding()
        }
    }
}

#Preview {
    ConfirmedMeetupScreen(meetupRequest: MeetupRequestDocument.mock())
}