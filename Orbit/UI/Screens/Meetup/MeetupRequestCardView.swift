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

    var body: some View {
        if !isHidden {
            let tags = meetupRequest.data.tags ?? ["Volunteering", "Meditation", "Bouldering"]
            let createdBy = meetupRequest.data.createdByUser
            let gender = createdBy?.gender ?? .man
            let age = 21
            let location = createdBy?.location ?? "MacEwan"

            NavigationLink(destination: MeetupRequestDetailedView(meetupRequest: meetupRequest)) {
                SwipeView {
                    HStack(alignment: .top, spacing: 12) {
                        // ⭕ Type icon
                        Circle()
                            .fill(ColorPalette.secondaryText(for: colorScheme).opacity(0.2))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: meetupRequest.data.type.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            //  ⚧ Gender + Age, 📍 Location
                            // 💬 Title (top)
                            Text(meetupRequest.data.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(ColorPalette.accent(for: colorScheme))
                                .lineLimit(2)

                            // gender + location (below title)
                            HStack(spacing: 8) {
                                
                                HStack(spacing: 4) {
                                    //gender
                                    Image(genderIcon(for: gender))
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))

                                    // age
                                    Text("\(age)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                                    
                                    Spacer().frame(width: 3)
                                    // 🕒 Clock icon + Time
                                        Image(systemName: "clock")
                                            .font(.system(size: 13))
                                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))

                                        Text(formatMeetupTime(meetup: meetupRequest.data))
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                                    }

                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.caption)
                                    Text(location)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 13, weight: .medium))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .foregroundColor(ColorPalette.text(for: colorScheme).opacity(0.85))
                                            .background(
                                                Capsule()
                                                    .fill(ColorPalette.secondaryText(for: colorScheme).opacity(0.15))
                                            )



                                    }
                                }
                            }

                        }

                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(ColorPalette.main(for: colorScheme))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                leadingActions: { _ in
                    SwipeAction {
                        approveMeetupRequest()
                    } label: { _ in
                        VStack(spacing: 4) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                            Text("Meetup").font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 60)
                    } background: { isHighlighted in
                        ColorPalette.accent(for: colorScheme).opacity(isHighlighted ? 0.8 : 1)
                    }.allowSwipeToTrigger()
                }
                trailingActions: { _ in
                    SwipeAction {
                        isHidden = true
                    } label: { _ in
                        VStack(spacing: 4) {
                            Image(systemName: "xmark.circle")
                                .font(.title2)
                            Text("Hide").font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 60)
                    } background: { isHighlighted in
                        Color.red.opacity(isHighlighted ? 0.8 : 1)
                    }.allowSwipeToTrigger()
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

    private func formatMeetupTime(meetup: MeetupRequestModel) -> String {
        guard let startTime = meetup.startTimeDate,
              let endTime = meetup.endTimeDate else {
            return "Invalid date"
        }

        let now = Date()

        if now >= startTime && now <= endTime {
            return "Now until \(DateFormatterUtility.formatTimeOnly(endTime))"
        }

        let minutesUntilStart = Calendar.current.dateComponents([.minute], from: now, to: startTime).minute ?? 0
        if minutesUntilStart > 0 && minutesUntilStart < 60 {
            return "in \(minutesUntilStart) minutes"
        }

        let isToday = Calendar.current.isDate(startTime, inSameDayAs: now)
        return isToday ? DateFormatterUtility.formatTimeOnly(startTime)
                       : DateFormatterUtility.formatForDisplay(startTime)
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
                                    .fill(ColorPalette.accent(for: colorScheme).opacity(0.3))
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )

                            .foregroundColor(ColorPalette.text(for: colorScheme))
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
            let tagWidth = tag.width(usingFont: .systemFont(ofSize: 14)) + 32 // estimate padding

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



#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme

    MeetupRequestCardView(meetupRequest: .mock())
        .environmentObject(MeetupRequestViewModel.mock())
        .environmentObject(ChatViewModel.mock())
        .environmentObject(UserViewModel.mock())
        .accentColor(ColorPalette.accent(for: colorScheme))

}
