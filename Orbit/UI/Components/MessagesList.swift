//
//  MessagesList.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct MessagesList: View {
<<<<<<< HEAD
=======
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environmen
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
    var conversations: [ConversationDetailModel]  //input

    
    var body: some View {
<<<<<<< HEAD
        List{
            ForEach(conversations){conversation in
                NavigationLink(destination: MessageView(conversationId: conversation.id, messagerName: conversation.messagerName)
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
=======
   
            
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
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
}

#Preview {
    MessagesList(conversations: [
        ConversationDetailModel(id: "conv1", messagerName: "John Doe", lastMessage: "Hey, how's it going?", timestamp: "Today", isRead: false),
        ConversationDetailModel(id: "conv2", messagerName: "Jane Smith", lastMessage: "Can we meet tomorrow?", timestamp: "Yesterday", isRead: false)
    ])
}
