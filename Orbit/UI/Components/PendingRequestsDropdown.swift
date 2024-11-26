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
    
    /// Only include pending requests where a request has been sent
    var pendingRequests: [UserModel] {
        // Get all users that we have sent requests to
        let sentToUserIds = chatRequestVM.requests.filter { request in
            request.data.status == .pending &&
            request.data.senderAccountId == userVM.currentUser?.accountId
        }.map { $0.data.receiverAccountId }
        
        // Get the corresponding UserModel objects
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
                    Text("Pending Requests")
                        .font(.headline)
                    if !pendingRequests.isEmpty {
                        Text("(\(pendingRequests.count))")
                            .foregroundColor(ColorPalette.text(for: colorScheme))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                }
                .padding(.vertical, 8)
                .foregroundColor(ColorPalette.text(for: colorScheme))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if isExpanded {
                VStack(spacing: 16) {
                    if pendingRequests.isEmpty {
                        Text("No pending requests")
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            .padding(.vertical, 8)
                    } else {
                        ForEach(pendingRequests) { user in
                            PendingUserCardView(
                                user: user,
                                currentUser: userVM.currentUser
                            )
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background(ColorPalette.lightGray(for: colorScheme))
        .cornerRadius(32)
        .animation(.spring(), value: isExpanded)
    }
}


