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
                Text(messageDocument.createdAt)
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
}

//#Preview {
//    MessageBox(
//        messageDocument: MessageModel(
//            conversationId: "12345", senderAccountId: "fdjkghkdfj",
//            message:
//                "I am the skibidi sigma. From the screen to the ring to the pen to the king.",
//            isRead: true)
//    ).environmentObject(UserViewModel.mock())
//}
