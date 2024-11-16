//
//  MessageBox.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI

struct MessageBox: View {
    var message: MessageModel
    var currentUser: UserModel
    @State private var showTime = false
    @State var isReceived = false
    
    var body: some View {
        let isReceived = message.senderAccountId != currentUser.accountId
        VStack(alignment:isReceived ? .leading :
                .trailing) {
                    HStack{
                        Text(message.message)
                            .padding()
                            .background(isReceived ? ColorPalette.lightGray(for: ColorScheme.light) : ColorPalette.accent(for: ColorScheme.light))
                            .cornerRadius(20)
                            .regularFont()
                    }
                    .frame(maxWidth: 300, alignment: isReceived ? .leading : .trailing)
                    .onTapGesture {
                        showTime.toggle()
                    }
                    
                    if showTime{
//                        Text(message.createdAt)
//                            .regularFont()
//                            .foregroundColor(.gray)
//                            .padding(isReceived ? .leading : .trailing, 25)
                    }
                    
                    
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: isReceived ? .leading : .trailing)
                .padding(isReceived ? .leading : .trailing)
                .padding(.horizontal, 10)
    }
}

#Preview {
    MessageBox(message: MessageModel(conversationId: "12345", senderAccountId: "fdjkghkdfj", message: "I am the skibidi sigma. From the screen to the ring to the pen to the king.", isRead: true), currentUser: UserModel(accountId: "sdghkjghkdfj", name: "Allen", interests: ["Pooping"], latitude: 752.56, longitude: 65.67, isInterestedToMeet: false, conversations: ["gdfgdsg"]))
}
