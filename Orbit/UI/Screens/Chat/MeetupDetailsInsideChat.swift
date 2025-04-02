//
//  MeetupDetailsInsideChat.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-30.
//
import SwiftUI

struct MeetupDetailsInsideChat: View {
    let user: UserModel
    let meetupRequest: MeetupRequestDocument
    let showFullDetails: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel

    var body: some View {
        ZStack(alignment: .top) {
            // Background (you might want to use the same background as MeetupRequestDetailedView)
            ColorPalette.background(for: colorScheme)
                .ignoresSafeArea()

            MeetupRequestAndUserInfoView(
                user: user, meetupRequest: meetupRequest,
                showFullDetails: showFullDetails)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        //            .navigationTitle(user.username)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.accentColor)
                        Text("back to chat")
                    }
                }
            }
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme

    MeetupDetailsInsideChat(
        user: UserModel.mock(), meetupRequest: .mock(), showFullDetails: true
    )
    .environmentObject(UserViewModel.mock())
    .accentColor(ColorPalette.accent(for: colorScheme))
}
