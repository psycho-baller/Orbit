//
//  PendingRequestsDropdown.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-11-25.
//

import SwiftUI

struct PendingRequestsDropdown: View {
    @EnvironmentObject private var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var isExpanded: Bool
    
    var pendingRequests: [UserModel] {
        let sentToUserIds = chatRequestVM.outgoingRequests.filter { request in
            request.data.status == .pending
        }.map { $0.data.receiverAccountId }
        
        return userVM.filteredUsers.filter { user in
            sentToUserIds.contains(user.accountId)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header button
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(
                        pendingRequests.isEmpty
                        ? "No Pending Requests"
                        : "^[\(pendingRequests.count) Pending Request](inflect: true)"
                    )
                    .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .padding(.vertical, 8)
                .foregroundColor(ColorPalette.text(for: colorScheme))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .disabled(pendingRequests.isEmpty)
            .opacity(pendingRequests.isEmpty ? 0.5 : 1)
            
            if isExpanded && !pendingRequests.isEmpty {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(pendingRequests) { user in
                            PendingUserCardView(
                                user: user,
                                currentUser: userVM.currentUser
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .frame(maxHeight: 300) // Limit the height of the scroll view
            }
        }
        .background(LightGrayOrMaterial())
        .cornerRadius(32)
        .animation(.spring(), value: isExpanded)
    }
}
