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
    @Binding var isTabHidden: Bool
    @State private var lastMessageId: String? = nil
    let messagerName: String

    
    var body: some View {
        VStack {
            VStack{
                ChatProfileTitle(messagerName: messagerName, isInMessageView: true)
                ScrollViewReader {proxy in
                    ScrollView{
                        ForEach($messages, id: \.id) {$messageDocument in
                            let status = messageDocument.data.senderAccountId.isEmpty
                            if !status{
                                //let isReceived = messageDocument.data.senderAccountId != (userVM.currentUser?.accountId ?? "")
                                MessageBox(message: MessageModel(conversationId: messageDocument.data.conversationId, senderAccountId: messageDocument.data.senderAccountId, message: messageDocument.data.message , createdAt: msgVM.formatTimestamp(messageDocument.data.createdAt)), currentUser: UserModel(accountId: userVM.currentUser?.accountId ?? "123", name: userVM.currentUser?.name ?? "Name", interests: userVM.currentUser?.interests, latitude: userVM.currentUser?.latitude, longitude: userVM.currentUser?.longitude, isInterestedToMeet: userVM.currentUser?.isInterestedToMeet, conversations: userVM.currentUser?.conversations))
                                
                                    .id(messageDocument.id)
                            }
                            
                        }
                    }
                    .onChange(of: lastMessageId) {oldMessageId, newMessageId in
                        
                        if let id = newMessageId {
                            withAnimation{
                                proxy.scrollTo(id, anchor: .bottom)
                            }
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
            isTabHidden = true
            Task {
                await loadMessages()
                await subscribeToMessages()
                await msgVM.markMessagesRead(conversationId: conversationId)  //should mark all messages in the conversation as read upon being in this view
            }
        }
        .onDisappear{
            isTabHidden = false
            Task{
                await msgVM.unsubscribeFromMessages()
            }
        }
        
    }
    
    private func loadMessages() async {
        
        messages = await msgVM.getMessages(conversationId)
        if let lastMessage = messages.last{
            lastMessageId = lastMessage.id
        }
    }

    private func sendMessage() {
        Task {
            if let senderId = userVM.currentUser?.accountId {
                await msgVM.createMessage(conversationId, senderId, newMessageText)
                DispatchQueue.main.async {
                    self.newMessageText = ""
                }
                await loadMessages()  // Refresh the messages to show the new one
            }
        }
    }
    
    private func subscribeToMessages() async {
        await msgVM.subscribeToMessages(conversationId: conversationId) {
            newMessage in
            DispatchQueue.main.async{
                print("Received new message: \(newMessage.data.message)")
                if !self.messages.contains(where: {$0.id == newMessage.id}){
                    self.messages.append(newMessage)
                    self.messages.sort { $0.data.createdAt < $1.data.createdAt }
                    self.lastMessageId = newMessage.id
                    
                }
                
            }
        }
    }
    
  
}



#Preview {
    MessageView(conversationId: "exampleConversationId", isTabHidden: .constant(false), messagerName: "Allen the Alien")
         .environmentObject(UserViewModel.mock())
         .environmentObject(MessagingViewModel())
}
