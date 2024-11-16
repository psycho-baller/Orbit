//
//  ChatProfileView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-03.
//

import SwiftUI

struct ChatProfileView: View {
    var name = "Allen the Alien"
    
    var body: some View {
        
        ZStack {
        
            VStack {
                VStack{
                    ChatProfileTitle(messagerName: name, isInMessageView: false)
                    
                    VStack{
                        
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                    .background(.white)
                    .cornerRadius(radius: 30, corners: [.topLeft, .topRight])
                }
                .background(ColorPalette.accent(for: ColorScheme.light))
                Rectangle()
                    .foregroundColor(.white)
            }
            
            VStack {
                HStack {
                        VStack(spacing: 10){
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundStyle(ColorPalette.accent(for: ColorScheme.light))
                                .font(.system(size: 40))
                            
                            VStack(alignment: .leading){
                                Text("Profile")
                                    .normalSemiBoldFont()
                            }
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                                
                        }
                        
                        VStack(spacing: 10){
                            Image(systemName: "bell")
                                .foregroundStyle(ColorPalette.accent(for: ColorScheme.light))
                                .font(.system(size: 40))
                            
                            VStack(alignment: .leading){
                                Text("Mute")
                                    .normalSemiBoldFont()
                            }
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                                
                        }
                        
                        VStack(spacing: 10){
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(ColorPalette.accent(for: ColorScheme.light))
                                .font(.system(size: 40))
                            
                            VStack(alignment: .leading){
                                Text("Options")
                                    .normalSemiBoldFont()
                            }
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                                
                        }
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(.white)
                
            }
             
                
            
            
            
           
        }
        
        
        
        
    }
}

#Preview {
    ChatProfileView()
}
