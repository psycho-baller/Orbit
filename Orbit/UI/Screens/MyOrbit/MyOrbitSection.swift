//
//  MyOrbitSection.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-17.
//

import SwiftUI

struct MyOrbitSection<Destination: View>: View {
    let title: String
    let requests: [MeetupRequestDocument]
    let destination: (MeetupRequestDocument) -> Destination  // 💡 Destination closure

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)

            if requests.isEmpty {
                Text("No \(title.lowercased()) found.")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            } else {
                ForEach(requests) { request in
                    NavigationLink(destination: destination(request)) {
                        MeetupRequestRow(meetupRequest: request.data)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8).fill(
                Color(UIColor.systemBackground)
            ).shadow(radius: 1))
    }
}

#Preview {
    MyOrbitSection(
        title: "My Meetup Requests",
        requests: [MeetupRequestDocument.mock()],
        destination: { _ in Text("Destination") }  // Placeholder for preview
    )
}
