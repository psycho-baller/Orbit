//
//  MessagesList.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct MessagesList: View {
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment
    var conversations: [ConversationDetailModel]  //input
    

    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(conversations) { conversation in
                    NavigationLink(
                        destination: MessageView(
                            conversationId: conversation.id,
                            messagerName: conversation.messagerName
                        )
                    ) {
                        InboxRow(
                            messagerName: conversation.messagerName,
                            lastMessage: conversation.lastMessage,
                            timestamp: conversation.timestamp,
                            isRead: conversation.isRead,
                            isCurrentUserSender: conversation.lastSenderId == userVM.currentUser?.accountId
                        )
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .background(ColorPalette.secondaryText(for: colorScheme))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    MessagesList(conversations: [
        ConversationDetailModel(id: "conv1", messagerName: "John Doe", lastMessage: "Hey, how's it going?", timestamp: "Today", isRead: false, lastSenderId: "845673845"),
        ConversationDetailModel(id: "conv2", messagerName: "Jane Smith", lastMessage: "Can we meet tomorrow?", timestamp: "Yesterday", isRead: false, lastSenderId: "285782564")
    ])
}
