//
//  MeetupApprovedRespondersSection.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-18.
//

import SwiftUI

struct MeetupRespondersSection: View {
    let chats: [ChatModel]
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Approved Responders")
                .font(.headline)
                .foregroundColor(ColorPalette.text(for: colorScheme))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(chats.compactMap { $0.otherUser }, id: \.id) {
                        user in
                        MeetupResponderRow(user: user)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 10)
    }
}

struct MeetupResponderRow: View {
    let user: UserModel

    var body: some View {
        VStack {
            if let profileUrl = user.profilePictureUrl,
                let url = URL(string: profileUrl)
            {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
            }

            Text(user.username)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(width: 60)
    }
}

#Preview {
    MeetupRespondersSection(chats: [ChatModel.mock()])
}
