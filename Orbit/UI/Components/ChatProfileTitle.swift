//
//  ChatProfileTitle.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-01.
//

import SwiftUI


struct ChatProfileTitle: View {
    var name: String = "Allen the Alien"
    var isInMessageView: Bool
    
    var body: some View {
        VStack(spacing: 10){
            Image(.alienorbit)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: isInMessageView ? 60 : 100, height:  isInMessageView ? 60 : 100 )
                .cornerRadius(50)
                
            
            
        
            VStack(alignment: .leading){
                Text(name)
                    .normalSemiBoldFont()
                   
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
            
        }
        .padding()
        
        
    }
}

#Preview {
    ChatProfileTitle(isInMessageView: true)
        .background(ColorPalette.accent(for: ColorScheme.light))
}