//
//  MessagesView.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

import SwiftUI
import Appwrite

struct MessagesView: View {
    @EnvironmentObject private var msgVM: MessagingViewModel
    @EnvironmentObject private var userVM: UserViewModel
    var body: some View {
        HStack {
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                Task {
                    if let currentUser = userVM.currentUser?.accountId {
                        print("participants: \(currentUser)")
                        await msgVM.createConversation([currentUser,"6726b1ef776f5badc4fe"])
                        // hard coded to bob
                    }
              }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        MessagesView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel.mock())
            .environmentObject(MessagingViewModel())
    }
#endif
