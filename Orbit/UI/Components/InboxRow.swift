//
//  InboxRow.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct InboxRow: View {
    var messagerName: String
    var lastMessage: String
    var timestamp: String
    var isRead: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            let formattedTimeStamp = formatTimestamp(timestamp)
            VStack {
                Spacer()
                if !isRead {
                    Circle()
                        .fill(ColorPalette.accent(for: ColorScheme.light))
                        .frame(width: 10, height: 10)
                }
                Spacer()

            }

            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(.systemGray4))

            VStack(alignment: .leading, spacing: 4) {

                Text(messagerName)
                    .normalSemiBoldFont()
                    .foregroundColor(ColorPalette.text(for: colorScheme))

                Text(lastMessage)
                    .regularFont()
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
            }

            HStack {
                Text(formattedTimeStamp)

            }
            .font(.footnote)
            .foregroundColor(.gray)

        }
        .padding(.horizontal)
        .frame(height: 72)

    }

    //timestamp displayed beside the conversation will display time only if newest message was sent within the same day and will display date only if newest message was sent before current date
    func formatTimestamp(_ timestamp: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd, h:mm a"
        inputFormatter.timeZone = TimeZone.current

        guard let date = inputFormatter.date(from: timestamp) else {
            return timestamp
        }

        let currentDate = Date()

        let dateDisplayFormatter = DateFormatter()
        dateDisplayFormatter.timeZone = TimeZone.current
        dateDisplayFormatter.dateStyle = .short
        dateDisplayFormatter.timeStyle = .none

        let timeDisplayFormatter = DateFormatter()
        timeDisplayFormatter.timeZone = TimeZone.current
        timeDisplayFormatter.dateStyle = .none
        timeDisplayFormatter.timeStyle = .short

        if Calendar.current.isDate(date, inSameDayAs: currentDate) {
            return timeDisplayFormatter.string(from: date)  // return only the time
        } else {
            return dateDisplayFormatter.string(from: date)  // return only the date
        }
    }
}

#Preview {
    InboxRow(
        messagerName: "Makka Pakka",
        lastMessage: "Makka Pakka Wakka Akka. Makka Pakka is coming for you",
        timestamp: "Yesterday", isRead: false)
}
