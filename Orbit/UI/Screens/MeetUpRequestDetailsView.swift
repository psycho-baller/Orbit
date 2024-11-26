//
//  MeetUpRequestDetailsView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-15.
//

import SwiftUI

struct MeetUpRequestDetailsView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    var request: ChatRequestDocument
    
    @State private var navigateToChat = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Meet-up request from \(userVM.getUserName(from: request.data.senderAccountId))")
                    .font(.headline)
                    .padding()
                
                Text(request.data.message)
                    .padding()
                
                HStack {
                    Button("Approve") {
                        Task {
                            await chatRequestVM.respondToMeetUpRequest(
                                requestId: request.id,
                                response: .approved
                            )
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    Button("Decline") {
                        Task {
                            await chatRequestVM.respondToMeetUpRequest(
                                requestId: request.id,
                                response: .declined
                            )
                            dismiss()
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            }
        }
        .onChange(of: chatRequestVM.newConversationId) { id in
            if let conversationId = id {
                navigateToChat = true
            }
        }
        .navigationDestination(isPresented: $navigateToChat) {
            if let conversationId = chatRequestVM.newConversationId {
                MessageView(
                    conversationId: conversationId,
                    messagerName: userVM.getUserName(from: request.data.senderAccountId)
                )
            }
        }
    }
}

#if DEBUG
    #Preview {
        MeetUpRequestDetailsView(
            request: (mockChatRequestDocument as? ChatRequestDocument)!
        )
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
    }
#endif

