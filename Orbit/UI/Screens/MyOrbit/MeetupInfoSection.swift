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
        VStack(alignment: .leading, spacing: 12) {
            HStack{
                Spacer()
                Text(meetupRequest.data.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
            MeetupPostInfoRow(icon: "clock", value: meetupRequest.data.startTimeDate?.formatted() ?? "Meetup Load Failed")
            
            MeetupPostInfoRow(icon: "mappin.circle", value: "Area ID: \(meetupRequest.data.areaId)")
            
            Text(meetupRequest.data.description)
            
            MeetupPostInfoRow(icon: MeetupRequestViewModel.iconForType(meetupRequest.data.type), value: meetupRequest.data.type.rawValue.capitalized)
            
            MeetupPostInfoRow(icon: MeetupRequestViewModel.iconForIntention(meetupRequest.data.intention), value: meetupRequest.data.intention.rawValue.capitalized)
        }
        
        .padding()
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal)
    }
}

struct MeetupPostInfoRow: View {
    let icon: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 24, height: 24)

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
