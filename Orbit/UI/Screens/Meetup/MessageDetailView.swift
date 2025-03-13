//
//  MessageDetailView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-09.
//

#warning ("Basic Outline to build off using hard coded data. Look at old implementation used in MessageView")


import SwiftUI

struct MessageDetailView: View {
    let request: ChatRequestDocument
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var messageText = ""
    
    var body: some View {
        ZStack {
            ColorPalette.background(for: colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Chat content
                ScrollView {
                    VStack(spacing: 16) {
                        MessageBubble(
                            message: request.data.message,
                            isFromSender: false
                        )
                    }
                    .padding()
                }
                
                // Bottom Action Bar
                VStack(spacing: 16) {
                    // Accept/Deny Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                        }) {
                            Text("Accept")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                        }) {
                            Text("Deny")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Message Input
                    HStack(spacing: 12) {
                        TextField("Hmm...", text: $messageText)
                            .padding(10)
                            .background(ColorPalette.main(for: colorScheme))
                            .cornerRadius(20)
                        
                        Button(action: {}) {
                            Image(systemName: "mic.fill")
                                .font(.title2)
                                .foregroundColor(ColorPalette.accent(for: colorScheme))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(ColorPalette.main(for: colorScheme))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

struct MessageBubble: View {
    let message: String
    let isFromSender: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if isFromSender { Spacer() }
            
            Text(message)
                .padding()
                .background(isFromSender ? 
                    ColorPalette.accent(for: colorScheme) :
                    ColorPalette.main(for: colorScheme))
                .foregroundColor(isFromSender ? .white : 
                    ColorPalette.text(for: colorScheme))
                .cornerRadius(20)
            
            if !isFromSender { Spacer() }
        }
    }
}

#Preview {
    MessageDetailView(request: .mock(data: .mock()))
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
}
