//
//  MessageView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI

struct MessageView: View {
    var messageArray = ["Hello", "How are you doing", "Makka Pakka Wakka Akka"]
    
    @EnvironmentObject private var msgVM: MessagingViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @State private var messages: [MessageDocument] = []
    @State private var newMessageText: String = ""
    let conversationId: String
    
    var body: some View {
        VStack {
            VStack{
                ChatProfileTitle(isInMessageView: true)
                
                ScrollView{
                    ForEach(messages, id: \.id) { messageDocument in
                        if (messageDocument.data.senderAccountId).isEmpty == false {
                            var isReceived = messageDocument.data.senderAccountId != (userVM.currentUser?.accountId ?? "")
                            MessageBox(message: Message(id: messageDocument.id, text: messageDocument.message, received: isReceived , timestamp: Date()))
                        }
                        
                    }
                }
                .padding(.top, 10)
                .background(.white)
                .cornerRadius(radius: 30, corners: [.topLeft, .topRight])
            }
            .background(ColorPalette.accent(for: ColorScheme.light))
            
            MessageField(text: $newMessageText, onSend: sendMessage)
            
        }
        .onAppear{
            Task {
                await loadMessages()
            }
        }
        
    }
    
    private func loadMessages() async {
        messages = await msgVM.getMessages(conversationId)
    }

    private func sendMessage() {
        Task {
            if let senderId = userVM.currentUser?.accountId {
                await msgVM.createMessage(conversationId, senderId, newMessageText)
                newMessageText = ""  // Clear the text field
                await loadMessages()  // Refresh the messages to show the new one
            }
        }
    }
}



#Preview {
    MessageView(conversationId: "exampleConversationId")
         .environmentObject(UserViewModel.mock())
         .environmentObject(MessagingViewModel())
}
