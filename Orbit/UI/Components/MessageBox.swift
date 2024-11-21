//
//  MessageBox.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI

struct MessageBox: View {
    var messageDocument: MessageDocument
    @EnvironmentObject var userVM: UserViewModel
    @State private var showTime = false
    @State var isReceived = false

    var body: some View {
        let isReceived =
            messageDocument.data.senderAccountId
            != userVM.currentUser?.accountId
        VStack(alignment: isReceived ? .leading : .trailing) {
            HStack {
                Text(messageDocument.data.message)
                    .padding()
                    .background(
                        isReceived
                            ? ColorPalette.lightGray(for: ColorScheme.light)
                            : ColorPalette.accent(for: ColorScheme.light)
                    )
                    .cornerRadius(20)
                    .regularFont()
            }
            .frame(maxWidth: 300, alignment: isReceived ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }

            if showTime {
                Text(formatTimestamp(messageDocument.createdAt))
                    .regularFont()
                    .foregroundColor(.gray)
                    .padding(isReceived ? .leading : .trailing, 25)
            }

        }
        .frame(
            maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/,
            alignment: isReceived ? .leading : .trailing
        )
        .padding(isReceived ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
    
    func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeZone = TimeZone.current
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        return "Unknown"
    }
    
    
}







