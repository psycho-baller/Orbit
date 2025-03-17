//
//  MeetupInfoSection.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-18.
//

import SwiftUI

struct MeetupInfoSection: View {
    let meetupRequest: MeetupRequestDocument
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            MeetupInfoRow(
                icon: "calendar", label: "Date",
                value: meetupRequest.data.startTimeDate?.formatted()
                    ?? "Unknown")
            MeetupInfoRow(
                icon: "mappin.circle", label: "Location",
                value: "Area ID: \(meetupRequest.data.areaId)")
            MeetupInfoRow(
                icon: "person.fill", label: "Created By",
                value: meetupRequest.data.createdByUser?.username ?? "Unknown")
            MeetupInfoRow(
                icon: "checkmark.circle.fill", label: "Status",
                value: meetupRequest.data.status.rawValue.capitalized)
        }
        .padding()
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal)
    }
}

struct MeetupInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    MeetupInfoSection(meetupRequest: MeetupRequestDocument.mock())
}
