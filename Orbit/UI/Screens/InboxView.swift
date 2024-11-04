//
//  InboxView.swift
//  Orbit
//
//  Created by Devon Tran on 2024-11-03.
//

import SwiftUI

struct InboxView: View {
    @State private var selectedTab: MessageTab = .messages
    @State private var showNewMessageView = false
    
    var body: some View {
        NavigationStack{
            ScrollView{
                
                HStack{
                    Button(action: {selectedTab = .messages}){
                        Text("Messages")
                            .normalSemiBoldFont()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == .messages ? ColorPalette.accent(for: ColorScheme.light) : ColorPalette.lightGray(for: ColorScheme.light))
                            .foregroundColor(.white )
                            .cornerRadius(10)
                        
                    }
                    .padding()
                    
                    Button(action: {selectedTab = .messages}){
                        Text("Requests")
                            .normalSemiBoldFont()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == .requests ? ColorPalette.accent(for: ColorScheme.light) : ColorPalette.lightGray(for: ColorScheme.light))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                    }
                    .padding()
                    
                }
                
                MessagesList()
                
                
            }
            .fullScreenCover(isPresented: $showNewMessageView, content: {Text("New Message")})
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 25))
                        
                        Text("Messages")
                            .largeBoldFont()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        showNewMessageView.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.black, Color(.systemGray5))
                    }
                }
            }
        }.background(ColorPalette.background(for: ColorScheme.light))
    }
}

enum MessageTab: String{
    case messages
    case requests
}

#Preview {
    InboxView()
}
