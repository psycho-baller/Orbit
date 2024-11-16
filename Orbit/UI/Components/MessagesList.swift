//
//  MessagesList.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct MessagesList: View {
    var conversations: [ConversationDetailModel]  //input
    @Binding var isTabHidden: Bool

    
    var body: some View {
        List{
            ForEach(conversations){conversation in
                NavigationLink(destination: MessageView(conversationId: conversation.id, isTabHidden: $isTabHidden, messagerName: conversation.messagerName)
                ){
                    InboxRow(
                        messagerName: conversation.messagerName, 
                        lastMessage: conversation.lastMessage,
                        timestamp: conversation.timestamp, 
                        isRead: conversation.isRead
                    )
                    
                }
               
            }
        }
        .listStyle(PlainListStyle())
        .frame(height: UIScreen.main.bounds.height - 120)
    }
}

#Preview {
    MessagesList(conversations: [
        ConversationDetailModel(id: "conv1", messagerName: "John Doe", lastMessage: "Hey, how's it going?", timestamp: "Today", isRead: false),
        ConversationDetailModel(id: "conv2", messagerName: "Jane Smith", lastMessage: "Can we meet tomorrow?", timestamp: "Yesterday", isRead: false)
    ], isTabHidden: .constant(false))
}
