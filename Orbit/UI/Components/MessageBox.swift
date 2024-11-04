//
//  MessageBox.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI

struct MessageBox: View {
    var message: Message
    @State private var showTime = false
    
    var body: some View {
        VStack(alignment: message.received ? .leading :
                .trailing) {
                    HStack{
                        Text(message.text)
                            .padding()
                            .background(message.received ? ColorPalette.lightGray(for: ColorScheme.light) : ColorPalette.accent(for: ColorScheme.light))
                            .cornerRadius(20)
                            .regularFont()
                    }
                    .frame(maxWidth: 300, alignment: message.received ? .leading : .trailing)
                    .onTapGesture {
                        showTime.toggle()
                    }
                    
                    if showTime{
                        Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                            .regularFont()
                            .foregroundColor(.gray)
                            .padding(message.received ? .leading : .trailing, 25)
                    }
                    
                    
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: message.received ? .leading : .trailing)
                .padding(message.received ? .leading : .trailing)
                .padding(.horizontal, 10)
    }
}

#Preview {
    MessageBox(message: Message(id: "12345", text: "I am the skibidi sigma. From the screen to the ring to the pen to the king.", received: false, timestamp: Date()))
}
