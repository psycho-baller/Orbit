//
//  MeetupRequestRow.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-17.
//

import SwiftUI

struct MeetupRequestRow: View {
    let meetupRequest: MeetupRequestModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(meetupRequest.title)
                .font(.headline)
                .foregroundColor(ColorPalette.text(for: colorScheme))

            Text("Status: \(meetupRequest.status.rawValue.capitalized)")
                .font(.subheadline)
                .foregroundColor(
                    meetupRequest.status == .active
                    ? ColorPalette.success(for: colorScheme) : ColorPalette.secondaryText(for: colorScheme))

            Text(
                "Date: \(meetupRequest.startTimeDate?.formatted() ?? "Unknown")"
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10).fill(
                Color(UIColor.systemBackground)
            ).shadow(radius: 1))
    }
}

#if DEBUG
    #Preview {
        MeetupRequestRow(meetupRequest: MeetupRequestModel.mock())
    }
#endif
