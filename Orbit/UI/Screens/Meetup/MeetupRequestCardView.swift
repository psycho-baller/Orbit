//
//  MeetupRequestCardView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//

import SwiftUI

struct MeetupRequestCardView: View {
    let meetupRequest: MeetupRequestDocument
    @EnvironmentObject var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isHidden = false
    private var computedSharedInterests: [String] {
        guard
            let otherUserInterests = meetupRequest.data.createdByUser?
                .activitiesHobbies,
            let myInterests = userVM.currentUser?.activitiesHobbies
        else {
            return []
        }
        var result = otherUserInterests.filter { myInterests.contains($0) }

        if let otherFriendActivities = meetupRequest.data.createdByUser?
            .friendActivities,
            let myFriendActivities = userVM.currentUser?.friendActivities
        {
            result.append(
                contentsOf: otherFriendActivities.filter {
                    myFriendActivities.contains($0)
                })
        }

        if let otherFriendshipQualities = meetupRequest.data.createdByUser?
            .friendshipQualities,
            let myFriendshipQualities = userVM.currentUser?.friendshipQualities
        {
            result.append(
                contentsOf: otherFriendshipQualities.filter {
                    myFriendshipQualities.contains($0)
                })
        }

        if let otherFriendshipValues = meetupRequest.data.createdByUser?
            .friendshipValues,
            let myFriendshipValues = userVM.currentUser?.friendshipValues
        {
            result.append(
                contentsOf: otherFriendshipValues.filter {
                    myFriendshipValues.contains($0)
                })
        }

        if let otherConvoTopics = meetupRequest.data.createdByUser?.convoTopics,
            let myConvoTopics = userVM.currentUser?.convoTopics
        {
            result.append(
                contentsOf: otherConvoTopics.filter {
                    myConvoTopics.contains($0)
                })
        }

        return result
    }

    var body: some View {
        if !isHidden {
            NavigationLink(
                destination: MeetupRequestDetailedView(
                    meetupRequest: meetupRequest)
            ) {
                SwipeView {
                    VStack(spacing: 10) {
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(
                                    ColorPalette.secondaryText(for: colorScheme)
                                        .opacity(0.2)
                                )
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(
                                        systemName: meetupRequest.data.type.icon
                                    )
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .foregroundColor(
                                        ColorPalette.accent(for: colorScheme)),
                                    alignment: .center
                                )

                            VStack(alignment: .leading, spacing: 8) {
                                Text(meetupRequest.data.title)
                                    .font(.title3.bold())
                                    .foregroundColor(
                                        ColorPalette.accent(for: colorScheme)
                                    )
                                    .lineLimit(1)

                                // Details row: gender, age, time, and location
                                HStack(spacing: 8) {
                                    // Gender and Age: Only if createdByUser exists
                                    if let createdByUser = meetupRequest.data
                                        .createdByUser,
                                        let gender = createdByUser.gender
                                    {
                                        HStack(spacing: 4) {
                                            Image(genderIcon(for: gender))
                                                .resizable()
                                                .renderingMode(.template)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(
                                                    ColorPalette.secondaryText(
                                                        for: colorScheme))

                                            // Show age only if it can be computed
                                            if let dob = createdByUser.dob,
                                                let age =
                                                    DateFormatterUtility.age(
                                                        from: dob)
                                            {
                                                Text("\(age)")
                                                    .font(
                                                        .system(
                                                            size: 14,
                                                            weight: .semibold)
                                                    )
                                                    .foregroundColor(
                                                        ColorPalette
                                                            .secondaryText(
                                                                for: colorScheme
                                                            ))
                                            }
                                        }
                                    }

                                    Spacer().frame(width: 3)

                                    // Clock icon and simplified time display
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 13))
                                            .foregroundColor(
                                                ColorPalette.secondaryText(
                                                    for: colorScheme))
                                        Text(
                                            formatMeetupTime(
                                                meetup: meetupRequest.data)
                                        )
                                        .font(
                                            .system(size: 14, weight: .semibold)
                                        )
                                        .foregroundColor(
                                            ColorPalette.secondaryText(
                                                for: colorScheme))
                                    }

                                    HStack(spacing: 4) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.caption)
                                        Text(
                                            userVM.getAreaName(
                                                forId: meetupRequest.data.areaId
                                            )
                                        )
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .font(
                                            .system(
                                                size: 14, weight: .semibold)
                                        )
                                    }
                                    .foregroundColor(
                                        ColorPalette.secondaryText(
                                            for: colorScheme))
                                }
                            }
                        }
                        if !computedSharedInterests.isEmpty {
                            InterestsHorizontalTags(
                                interests: computedSharedInterests,
                                onTapInterest: { interest in
                                    print("clicked")
                                }
                            )
//                            Spacer()
                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(ColorPalette.main(for: colorScheme))
                            .shadow(
                                color: .black.opacity(0.05), radius: 4,
                                x: 0,
                                y: 2)
                    )
                } leadingActions: { _ in
                    SwipeAction {
                        approveMeetupRequest()
                    } label: { _ in
                        VStack(spacing: 4) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                            Text("Meetup")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 60)
                    } background: { isHighlighted in
                        ColorPalette.accent(for: colorScheme).opacity(
                            isHighlighted ? 0.8 : 1)
                    }
                    .allowSwipeToTrigger()
                } trailingActions: { _ in
                    SwipeAction {
                        isHidden = true
                    } label: { _ in
                        VStack(spacing: 4) {
                            Image(systemName: "xmark.circle")
                                .font(.title2)
                            Text("Hide")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 60)
                    } background: { isHighlighted in
                        Color.red.opacity(isHighlighted ? 0.8 : 1)
                    }
                    .allowSwipeToTrigger()
                }
                .swipeOffsetCloseAnimation(stiffness: 500, damping: 600)
                .swipeOffsetExpandAnimation(stiffness: 500, damping: 600)
                .swipeOffsetTriggerAnimation(stiffness: 500, damping: 600)
                .swipeMinimumDistance(20)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func approveMeetupRequest() {
        guard let sender = userVM.currentUser else { return }
        let newChat = ChatModel(
            createdByUser: sender,
            otherUser: meetupRequest.data.createdByUser!,
            meetupRequest: meetupRequest.data
        )
        Task {
            await chatVM.createChat(chat: newChat)
        }
    }

    /// Simplified time formatter: returns only the start time (e.g. "10:00 AM")
    private func formatMeetupTime(meetup: MeetupRequestModel) -> String {
        guard let startTime = meetup.startTimeDate else {
            return "Invalid date"
        }
        return DateFormatterUtility.formatTimeOnly(startTime)
    }
}

struct FlexibleTagView: View {
    let tags: [String]
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(generateLines(from: tags), id: \.self) { line in
                HStack(spacing: 8) {
                    ForEach(line, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .foregroundColor(.white.opacity(0.9))
                            .background(
                                Capsule()
                                    .fill(
                                        ColorPalette.accent(for: colorScheme)
                                            .opacity(0.3)
                                    )
                                    .shadow(
                                        color: .black.opacity(0.1), radius: 2,
                                        x: 0, y: 1)
                            )
                    }
                }
            }
        }
    }

    private func generateLines(from tags: [String]) -> [[String]] {
        var lines: [[String]] = [[]]
        var currentLineWidth: CGFloat = 0
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 100

        for tag in tags {
            let tagWidth = tag.width(usingFont: .systemFont(ofSize: 14)) + 32  // estimated padding
            if currentLineWidth + tagWidth > maxWidth {
                lines.append([tag])
                currentLineWidth = tagWidth
            } else {
                lines[lines.count - 1].append(tag)
                currentLineWidth += tagWidth
            }
        }
        return lines
    }
}

extension String {
    func width(usingFont font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: attributes).width
    }
}

private func genderIcon(for gender: UserGender) -> String {
    switch gender {
    case .man: return "icon_gender_male"
    case .woman: return "icon_gender_female"
    case .nonBinary, .other: return "icon_gender_nonbinary"
    }
}

#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme
        MeetupRequestCardView(meetupRequest: .mock())
            .environmentObject(MeetupRequestViewModel.mock())
            .environmentObject(ChatViewModel.mock())
            .environmentObject(UserViewModel.mock())
            .accentColor(ColorPalette.accent(for: colorScheme))
    }
#endif
