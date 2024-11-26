//
//  MessagesList.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct MessagesList: View {
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environmen
    var conversations: [ConversationDetailModel]  //input

    
    var body: some View {
   
            
            List{
                ForEach(conversations){conversation in
                    NavigationLink(destination: MessageView(conversationId: conversation.id, messagerName: conversation.messagerName)
                    ){
                        HStack{
                            InboxRow(
                                messagerName: conversation.messagerName,
                                lastMessage: conversation.lastMessage,
                                timestamp: conversation.timestamp,
                                isRead: conversation.isRead
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                       
                        
                        
                    }
                    
                    .listRowBackground(ColorPalette.background(for: colorScheme))
                    
                    
                    
                }
            }
            .listStyle(PlainListStyle())
            .frame(height: UIScreen.main.bounds.height - 120)
            //.scrollContentBackground(.hidden)
            //.background(ColorPalette.background(for: colorScheme))
           
            
            
        }
}

#Preview {
    MessagesList(conversations: [
        ConversationDetailModel(id: "conv1", messagerName: "John Doe", lastMessage: "Hey, how's it going?", timestamp: "Today", isRead: false),
        ConversationDetailModel(id: "conv2", messagerName: "Jane Smith", lastMessage: "Can we meet tomorrow?", timestamp: "Yesterday", isRead: false)
    ])
}
