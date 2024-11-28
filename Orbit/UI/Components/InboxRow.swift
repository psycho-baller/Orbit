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
            if !isRead {
                Circle()
                    .fill(ColorPalette.accent(for: ColorScheme.light))
                    .frame(width: 10, height: 10)
            }
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(.systemGray4))
            
            VStack (alignment: .leading, spacing: 4){
               
                Text(messagerName)
                    .normalSemiBoldFont()
                
                Text(lastMessage)
                    .regularFont()
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading )
            }
            
            HStack{
                Text(formatTimestamp(timestamp))
                
            }
            .font(.footnote)
            .foregroundColor(.gray)
            
        }
        .padding(.horizontal)
        .frame(height: 72)
        
    }
    
    func formatTimestamp(_ timestamp: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = isoFormatter.date(from: timestamp) else {
            return timestamp
        }
        
        let currentDate = Date()
        
        //date only
        let dateDisplayFormatter = DateFormatter()
        dateDisplayFormatter.timeZone = TimeZone.current
        dateDisplayFormatter.dateStyle = .short
        dateDisplayFormatter.timeStyle = .none
        
        //time only
        let timeDisplayFormatter = DateFormatter()
        timeDisplayFormatter.timeZone = TimeZone.current
        timeDisplayFormatter.dateStyle = .none
        timeDisplayFormatter.timeStyle = .short
        
        let formattedCurrentDate = dateDisplayFormatter.string(for: currentDate)
        let formattedDate = dateDisplayFormatter.string(for: date)
        
        if formattedCurrentDate == formattedDate {
            return timeDisplayFormatter.string(for: date) ?? timestamp
        } else {
            return dateDisplayFormatter.string(for: date) ?? timestamp
        }
       
    }
}

#Preview {
    InboxRow(messagerName: "Makka Pakka", lastMessage: "Makka Pakka Wakka Akka. Makka Pakka is coming for you", timestamp: "Yesterday", isRead: false )
}
