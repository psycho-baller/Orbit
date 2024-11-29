//
//  MessageView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI
import MapKit

struct MessageView: View {
    @EnvironmentObject private var msgVM: MessagingViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isLocationChoicePresented: Bool = false
    @State private var sharedLocation: CLLocationCoordinate2D?
    //@State private var selectedLocation: CLLocationCoordinate2D?

    @State private var newMessageText: String = ""
    @State private var scrollToId: String?  // Save the last message ID for scroll position
    let conversationId: String
    let messagerName: String


    var body: some View {
        VStack {
            VStack {
                // Chat Header
                ChatProfileTitle(
                    messagerName: messagerName, isInMessageView: true)

                    ScrollView {
                        ForEach($msgVM.messages, id: \.id) { $messageDocument in
                            if !messageDocument.data.senderAccountId.isEmpty {
                                MessageBox(
                                    messageDocument: messageDocument,
                                    sharedLocation: $sharedLocation
                                )
                                    .id(messageDocument.id)  // Assign unique ID to each message
                            }
                        }
                    }
                    .defaultScrollAnchor(.bottom)
                    .padding(.bottom, 10)
                    .background(colorScheme == .light ? .white : ColorPalette.background(for: colorScheme))
                    .cornerRadius(radius: 30, corners: [.topLeft, .topRight])
            }
            .background(colorScheme == .light ? ColorPalette.accent(for: ColorScheme.light) : ColorPalette.background(for: colorScheme))
            
            HStack{
                Button(action: {isLocationChoicePresented.toggle()})
                {
                    Image(systemName: "mappin.and.ellipse.circle.fill")
                        .foregroundColor(colorScheme == .light ? .white : Color(.systemGray5))
                        .padding(10)
                        .background(ColorPalette.accent(for: ColorScheme.light))
                        .cornerRadius(50)
                }
                .padding(.leading, 10)
                
                // Message Input Field
                MessageField(text: $newMessageText, onSend: sendMessage)
            }
       
        }
        .onAppear {
            Task {
                // Fetch messages and subscribe to updates
                await msgVM.getMessages(conversationId)
                await msgVM.subscribeToMessages(
                    conversationId: conversationId
                ) { newMessage in
                    DispatchQueue.main.async{
                        print(
                            "MessageView - Received new message: \(newMessage.data.message)")

                        if !msgVM.messages.contains(where: {
                            $0.id == newMessage.id
                        }) {
                            msgVM.messages.append(newMessage)
                            msgVM.messages.sort { $0.createdAt < $1.createdAt }
                            msgVM.lastMessageId = newMessage.id
                        }
                        
                        Task{
                            if let currentUserId = userVM.currentUser?.accountId {
                                await msgVM.markMessagesRead(conversationId: conversationId, currentAccountId: currentUserId)
                            }
                            
                        }
                    }
                        
                   
                }
                if let currentUserId = userVM.currentUser?.accountId {
                    await msgVM.markMessagesRead(conversationId: conversationId, currentAccountId: currentUserId)
                }
            }
        }
        .onDisappear {
            Task {
                await msgVM.unsubscribeFromMessages()
                print("MessageView - Unsubscribed from messages")
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $isLocationChoicePresented) {  //sheet for location sharing
            ZStack{
                Color(ColorPalette.background(for: colorScheme))
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0){
                    HStack {
                        Button("Close"){
                            isLocationChoicePresented = false
                        }
                        .foregroundColor(colorScheme == .light ? .black : .white)
        
                        Spacer()
                    }
                    .overlay(
                        Text("Location")
                            .normalSemiBoldFont()
                            .frame(maxWidth: .infinity, alignment: .center)
                    
                    )
                    .padding()
                    .background(ColorPalette.background(for: colorScheme).ignoresSafeArea(.all))
                    
                    if let currentLocation = userVM.currentLocation {
                        LocationChoosingView(
                            initialCoordinate: currentLocation,
                            pinLocation:Binding(get: { msgVM.currentLocation ?? currentLocation },
                                                set: { msgVM.currentLocation = $0
                                                    
                                                    /*newCoordinate in
                                                    msgVM.currentLocation = newCoordinate
                                                    newMessageText = msgVM.encodeCoordinate(newCoordinate)
                                                    sendMessage()
                                            
                                                    print("The new coordinate is \(newCoordinate)") */
                                                 }
                                                ),
                            onShareLocation: { selectedLocation in
                                isLocationChoicePresented = false
                                newMessageText = msgVM.encodeCoordinate(selectedLocation)
                                sendMessage()
                                print("The new coordinate is \(selectedLocation)")
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(ColorPalette.background(for: colorScheme)).ignoresSafeArea(.all))
                    } else {
                        Text("Cannot determine location")
                    }
                    
                    
                }
                
            }
            
        }
        .background(Color(ColorPalette.background(for: colorScheme)).ignoresSafeArea())
        
    }
    private func sendMessage() {
        Task {
            if let senderId = userVM.currentUser?.accountId {
                await msgVM.createMessage(
                    conversationId: conversationId, senderAccountId: senderId,
                    message: newMessageText)
                newMessageText = ""
            }
        }
    }
}

#Preview {
    MessageView(
        conversationId: "exampleConversationId",
        messagerName: "Allen the Alien"
    )
    .environmentObject(UserViewModel.mock())
    .environmentObject(MessagingViewModel())
}
