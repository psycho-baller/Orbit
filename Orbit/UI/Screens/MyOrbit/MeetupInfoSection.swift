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
    @EnvironmentObject var userVM: UserViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Spacer()
                Text(meetupRequest.data.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                Spacer()
            }

            Text(meetupRequest.data.description)
            if let startDate = meetupRequest.data
                .startTimeDate,
                let endDate = meetupRequest.data.endTimeDate
            {
                MeetupPostInfoRow(
                    icon: "clock",
                    value:
                        "\(DateFormatterUtility.formatForDisplay(startDate)) - \(DateFormatterUtility.formatTimeOnly(endDate))"
                )
            }

            MeetupPostInfoRow(
                icon: "mappin.circle",
                value: userVM.getAreaName(forId: meetupRequest.data.areaId))

            MeetupPostInfoRow(
                icon: meetupRequest.data.type.icon,
                value: meetupRequest.data.type.rawValue.capitalized)

            MeetupPostInfoRow(
                icon: meetupRequest.data.intention.icon,
                value: meetupRequest.data.intention.rawValue.capitalized)
        }

        .padding()
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct MeetupPostInfoRow: View {
    let icon: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 28)

            Text(value)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme

    MeetupInfoSection(meetupRequest: MeetupRequestDocument.mock())
        .environmentObject(UserViewModel.mock())
        .accentColor(ColorPalette.accent(for: colorScheme))
}
