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
    @Environment(\.colorScheme) var colorScheme
    @State private var showChat = false
    var request: ChatRequestDocument
    var approveRequest: (ChatRequestDocument) async -> Void
    var declineRequest: (ChatRequestDocument) async -> Void
    
    var body: some View {
        if let sender = userVM.users.first(where: { $0.accountId == request.data.senderAccountId }) {
            ZStack {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    ProfilePageView(user: sender)
                        .padding(.bottom, 80)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            Task {
                                await approveRequest(request)
                                dismiss()
                            }
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                        
                        Button(action: {
                            Task {
                                await declineRequest(request)
                                dismiss()
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                }
            }
            .onChange(of: chatRequestVM.newConversationId) { _, newValue in
                if newValue != nil {
                    showChat = true
                }
            }
            .sheet(isPresented: $showChat) {
                if let conversationId = chatRequestVM.newConversationId {
                    NavigationStack {
                        MessageView(conversationId: conversationId, messagerName: sender.firstName + " " + (sender.lastName ?? ""))
                    }
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        MeetUpRequestDetailsView(
            request: (mockChatRequestDocument as? ChatRequestDocument)!,
            approveRequest: { _ in
                print("Approveds")
            },
            declineRequest: { _ in
                print("Declined")
            }
        )
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
    }
#endif
