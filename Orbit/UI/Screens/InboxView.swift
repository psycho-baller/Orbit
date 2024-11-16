//
//  InboxView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-03.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject private var msgVM: MessagingViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @State private var selectedTab: MessageTab = .messages
    @State private var showNewMessageView = false
    @State private var conversations: [ConversationDetailModel] = []
    @Binding var isTabHidden: Bool
    @State private var subscriptionTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack{
            ScrollView{
                
                HStack{
                    Button(action: {selectedTab = .messages}){
                        Text("Messages")
                            .normalSemiBoldFont()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == .messages ? ColorPalette.accent(for: ColorScheme.light) : ColorPalette.lightGray(for: ColorScheme.light))
                            .foregroundColor(.white )
                            .cornerRadius(10)
                        
                    }
                    .padding()
                    
                    Button(action: {selectedTab = .messages}){
                        Text("Requests")
                            .normalSemiBoldFont()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == .requests ? ColorPalette.accent(for: ColorScheme.light) : ColorPalette.lightGray(for: ColorScheme.light))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                    }
                    .padding()
                    
                }
                
                if userVM.currentUser == nil {
                    ProgressView("Loading User Info")
                }else{
                    MessagesList(conversations: conversations, isTabHidden: $isTabHidden)
                }
                
                
            }
            .onChange(of: userVM.currentUser){
                if userVM.currentUser == nil{
                    print("Still loading user")
                } else{
                    Task{
                        await loadConversations()
                    }
                }
              
            }
            //.navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 25))
                        
                        Text("Messages")
                            .largeBoldFont()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        showNewMessageView.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.black, Color(.systemGray5))
                    }
                }
            }
            .fullScreenCover(isPresented: $showNewMessageView, content: {Text("New Message")})
            .onAppear{
                print("InboxView - onAppear: UserViewModel currentUser: \(userVM.currentUser?.accountId ?? "nil")")
                Task {
                   await loadConversations()
                    subscribeToMessages()

                }
            }
            .onDisappear{
                //subscriptionTask?.cancel()
            }
        }.background(ColorPalette.background(for: ColorScheme.light))
    }
    
    private func loadConversations() async {
        print("Loading Conversations")
        
        if let userId = userVM.currentUser?.accountId {
            print("User ID: \(userId)")
            conversations = await msgVM.getConversationDetails(userId)
            print("Loaded Conversations")
        }else {
            print("User ID not found")
        }
    }
    
    
    private func subscribeToMessages(){  //meant to listen for new messages and reload the page, this isn't fully working yet
        subscriptionTask = Task {
            await msgVM.subscribeToMessages(conversationId: "") { _ in
                Task {
                    await loadConversations()
                }
            }
        }
    }
}

enum MessageTab: String{
    case messages
    case requests
}

#Preview {
    InboxView(isTabHidden: .constant(false))
        .environmentObject(UserViewModel.mock())
        .environmentObject(MessagingViewModel())
    
}
