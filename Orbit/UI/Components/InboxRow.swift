//
//  InboxRow.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct InboxRow: View {
    var messagerName: String
    var lastMessage: String
    var timestamp: String
    var isRead: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(Color(.systemGray4))
            
            VStack (alignment: .leading, spacing: 4){
                if !isRead {
                    Circle()
                        .fill(ColorPalette.button(for: ColorScheme.light))
                }
                Text(messagerName)
                    .normalSemiBoldFont()
                
                Text(lastMessage)
                    .regularFont()
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading )
            }
            
            HStack{
                Text(timestamp)
                Image(systemName: "chevron.right")
            }
            .font(.footnote)
            .foregroundColor(.gray)
            
        }
        .padding(.horizontal)
        .frame(height: 72)
        
    }
}

#Preview {
    InboxRow(messagerName: "Makka Pakka", lastMessage: "Makka Pakka Wakka Akka. Makka Pakka is coming for you", timestamp: "Yesterday", isRead: false )
}
