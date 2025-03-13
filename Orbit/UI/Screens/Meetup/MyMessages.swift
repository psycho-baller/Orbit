//
//  MyMessages.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-09.
//

#warning ("Basic Outline to build off using hard coded data, Change to look like design, use real data, and navigate")

import SwiftUI

struct MyMessages: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Using MockData for preview
                        #warning ("TODO - Use real data")
                        ForEach(MockData.chatRequests) { request in
                            MessageRequestRow(request: request)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("My Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MessageRequestRow: View {
    let request: ChatRequestDocument
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            if let user = userVM.users.first(where: { $0.accountId == request.data.senderAccountId }),
               let profileUrl = user.profilePictureUrl,
               let url = URL(string: profileUrl)
            {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(request.data.message)
                    .font(.headline)
                    .foregroundColor(ColorPalette.text(for: colorScheme))
                
                Text("What's your favorite food place in MacHall?")
                    .font(.subheadline)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
            }
            
            Spacer()
            
        }
        .padding()
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(12)
    }
}

// Mock Data
struct MockData {
    static let chatRequests: [ChatRequestDocument] = [
        .mock(data: ChatRequestModel(
            senderAccountId: "user1",
            receiverAccountId: "currentUser",
            message: "Hey! I would love to meet with you!",
            status: .pending
        )),
        .mock(data: ChatRequestModel(
            senderAccountId: "user2",
            receiverAccountId: "currentUser",
            message: "What's your favorite food place in MacHall?",
            status: .pending
        ))
    ]
}

#if DEBUG
#Preview {
    MyMessages()
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
        .environmentObject(AppState())
}
#endif
