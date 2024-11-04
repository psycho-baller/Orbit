//
//  MessageView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI

struct MessageView: View {
    var messageArray = ["Hello", "How are you doing", "Makka Pakka Wakka Akka"]
    
    var body: some View {
        VStack {
            VStack{
                ChatProfileTitle(isInMessageView: true)
                
                ScrollView{
                    ForEach(messageArray, id: \.self) { text in MessageBox(message: Message(id: "12345", text: text, received: true , timestamp: Date()))
                        
                    }
                }
                .padding(.top, 10)
                .background(.white)
                .cornerRadius(radius: 30, corners: [.topLeft, .topRight])
            }
            .background(ColorPalette.accent(for: ColorScheme.light))
            
            MessageField()
            
        }
        
    }
}

#Preview {
    MessageView()
}
