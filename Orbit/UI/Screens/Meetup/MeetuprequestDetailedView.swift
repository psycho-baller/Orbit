//
//  MeetuprequestDetailedView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-02-21.
//

import SwiftUI

struct MeetupRequestDetailedView: View {
    let meetupRequest: MeetupRequestModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var meetupApprovalVM: MeetupApprovalViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var areaName: String = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        if let profileUrl = meetupRequest.createdByUser?
                            .profilePictureUrl,
                            let url = URL(string: profileUrl)
                        {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(
                                        ColorPalette.secondaryText(
                                            for: colorScheme))
                            }
                        }
                        Text(meetupRequest.createdByUser?.username ?? "")
                            .font(.title)
                            .padding(.bottom, 1)
                            .foregroundColor(Color.accentColor)
                            .lineLimit(1)

                        VStack(alignment: .leading, spacing: 16) {
                            // Title
                            Text(meetupRequest.title)
                                .font(.title3)
                                .fontWeight(.semibold)

                            // Time
                            HStack(spacing: 12) {
                                Image(systemName: "clock")
                                    .frame(width: 24)
                                if let startDate = meetupRequest.startTimeDate,
                                    let endDate = meetupRequest.endTimeDate
                                {
                                    Text(
                                        "\(DateFormatterUtility.formatForDisplay(startDate)) - \(DateFormatterUtility.formatTimeOnly(endDate))"
                                    )
                                } else {
                                    Text("Invalid date format")
                                }
                            }
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))

                            #warning(
                                "TODO: Make Location work"
                            )
                            // Area
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .frame(width: 24)
                                Text(areaName)
                            }
                            .foregroundColor(
                                ColorPalette.secondaryText(for: colorScheme))

                            // Description
                            Text(meetupRequest.description)
                                .font(.body)

                            // Type and Intention
                            HStack(spacing: 12) {
                                Image(
                                    systemName: iconForType(meetupRequest.type)
                                )
                                .frame(width: 24)
                                Text(meetupRequest.type.rawValue.capitalized)
                            }
                            .foregroundColor(
                                ColorPalette.accent(for: colorScheme))

                            HStack(spacing: 12) {
                                Image(
                                    systemName: iconForIntention(
                                        meetupRequest.intention)
                                )
                                .frame(width: 24)
                                Text(
                                    meetupRequest.intention.rawValue.capitalized
                                )
                            }
                            .foregroundColor(
                                ColorPalette.accent(for: colorScheme))
                        }
                        .padding()
                        .background(ColorPalette.main(for: colorScheme))
                        .cornerRadius(16)
                        .padding(.horizontal, 12)

                        // Interests Section
                        if !allInterests.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Interests")
                                    .font(.headline)
                                    .foregroundColor(
                                        ColorPalette.text(for: colorScheme))

                                InterestsHorizontalTags(
                                    interests: allInterests,
                                    onTapInterest: { _ in }
                                )
                                #warning(
                                    "TODO: Add common interests"
                                )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        }
                        Text(meetupRequest.createdByUser?.bio ?? "")
                            .padding()

                    }
                }

                HStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await meetupApprovalVM.declineMeetup(meetupRequest: meetupRequest)
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Decline")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(16)
                    }
                    
                    Button(action: approveMeetupRequest) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Accept")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(16)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                                Button(role: .destructive) {
                                    Task {
                                        if let userId = meetupRequest.createdByUser?.id {
                                            await userVM.blockUser(userId: userId)
                                            dismiss() // Dismiss after blocking
                                        }
                                    }
                                } label: {
                                    Label("Block User", systemImage: "nosign")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle") // Three-dot menu
                                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            }
                        }
                    }

        }
        .onAppear {
            areaName = userVM.getAreaName(forId: meetupRequest.areaId)
        }
    }

    // helper function to get icon for meetup type
    private func iconForType(_ type: MeetupType) -> String {
        switch type {
        case .coffee: return "cup.and.saucer.fill"
        case .meal: return "fork.knife"
        case .indoorActivity: return "house.fill"
        case .outdoorActivity: return "figure.hiking"
        case .event: return "calendar"
        case .other: return "ellipsis.circle.fill"
        }
    }

    // helper function to get icon for meetup intention
    private func iconForIntention(_ intention: MeetupIntention) -> String {
        switch intention {
        case .friendship: return "figure.2"
        case .relationship: return "heart.fill"
        }
    }

    private var allInterests: [String] {
        meetupRequest.createdByUser?.personalPreferences?.activitiesHobbies
            ?? []
    }

    private func approveMeetupRequest() {
        guard let currentUser = userVM.currentUser else {
            print("Error: Current user is nil.")
            return
        }

        let meetupApproval = MeetupApprovalModel(
            //            approvedByUserId: currentUser.id,
            approvedByUser: currentUser,
            //            meetupRequestId: meetupRequest.id,
            meetupRequest: meetupRequest
        )

        Task {
            await meetupApprovalVM.approveMeetup(approval: meetupApproval)
            dismiss()
        }
    }

   
}

#if DEBUG
    struct MeetupRequestDetailedView_Previews: PreviewProvider {
        static var previews: some View {
            MeetupRequestDetailedView(meetupRequest: .mock())
                .environmentObject(UserViewModel.mock())
                .environmentObject(MeetupRequestViewModel.mock())
                .environmentObject(MeetupApprovalViewModel())
        }
    }
#endif
