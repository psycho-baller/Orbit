//
//  MyMessages.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-09.
//

import SwiftUI

struct MyMessages: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var chatRequests: [ChatRequestDocument] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue.opacity(0.9).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(chatRequests, id: \ .id) { request in
                            MessageRequestRow(request: request)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("My Messages")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await chatRequestVM.fetchChatRequests()
                }
                
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
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(userVM.getUserName(from: request.data.senderAccountId))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(request.data.message)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
        }
    }
}
#if DEBUG
    #Preview {
        let sender: UserModel = .mock()
        let receiver: UserModel = .mock2()
        ChatRequestView(sender: sender, receiver: receiver)
            .environmentObject(ChatRequestViewModel.mock())
    }
#endif

