//
//  InboxRow.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-04.
//

import SwiftUI

struct InboxRow: View {
<<<<<<< HEAD
=======
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
    var messagerName: String
    var lastMessage: String
    var timestamp: String
    var isRead: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12){
<<<<<<< HEAD
            if !isRead {
                Circle()
                    .fill(ColorPalette.button(for: ColorScheme.light))
                    .frame(width: 10, height: 10)
            }
=======
            let formattedTimeStamp = formatTimestamp(timestamp)
            VStack{
                Spacer()
                if !isRead {
                    Circle()
                        .fill(ColorPalette.button(for: ColorScheme.light))
                        .frame(width: 10, height: 10)
                }
                Spacer()
                
            }
            
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(.systemGray4))
            
            VStack (alignment: .leading, spacing: 4){
               
                Text(messagerName)
                    .normalSemiBoldFont()
<<<<<<< HEAD
=======
                    .foregroundColor(ColorPalette.text(for: colorScheme))
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                
                Text(lastMessage)
                    .regularFont()
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading )
            }
            
            HStack{
<<<<<<< HEAD
                Text(formatTimestamp(timestamp))
=======
                Text(formattedTimeStamp)
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                
            }
            .font(.footnote)
            .foregroundColor(.gray)
            
        }
<<<<<<< HEAD
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
=======
        //.frame(maxWidth: .infinity)
        //.background(ColorPalette.background(for: colorScheme))
        .padding(.horizontal, 0)
        .frame(height: 72)
        
    }
   
    
    //timestamp displayed beside the conversation will display time only if newest message was sent within the same day and will display date only if newest message was sent before current date
    func formatTimestamp(_ timestamp: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd, h:mm a"
        inputFormatter.timeZone = TimeZone.current
         
        guard let date = inputFormatter.date(from: timestamp) else {
            return timestamp
        }
         
        let currentDate = Date()
        
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        let dateDisplayFormatter = DateFormatter()
        dateDisplayFormatter.timeZone = TimeZone.current
        dateDisplayFormatter.dateStyle = .short
        dateDisplayFormatter.timeStyle = .none
        
<<<<<<< HEAD
        //time only
=======
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        let timeDisplayFormatter = DateFormatter()
        timeDisplayFormatter.timeZone = TimeZone.current
        timeDisplayFormatter.dateStyle = .none
        timeDisplayFormatter.timeStyle = .short
        
<<<<<<< HEAD
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
=======
         
        if Calendar.current.isDate(date, inSameDayAs: currentDate) {
              return timeDisplayFormatter.string(from: date) // return only the time
          } else {
              return dateDisplayFormatter.string(from: date) // return only the date
          }
     }
}

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
