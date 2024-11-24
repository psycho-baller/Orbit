//
//  MeetUpRequestDetailsView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-15.
//

import SwiftUI

struct MeetUpRequestDetailsView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    var request: ChatRequestDocument

    var body: some View {
        VStack {
            Text(
                "Meet-up request from \(userVM.getUserName(from: request.data.senderAccountId))"
            )
            .font(.headline)
            .padding()

            Text(request.data.message)
                .padding()

            HStack {
                Button("Approve") {
                    Task {
                        await chatRequestVM.respondToMeetUpRequest(
                            requestId: request.id,
                            response: .approved
                        )
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Button("Decline") {
                    Task {
                        await chatRequestVM.respondToMeetUpRequest(
                            requestId: request.id,
                            response: .declined
                        )
                        dismiss()
                    }
                }
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .navigationTitle("Meet-Up Request")
        .alert(
            "Error", isPresented: .constant(chatRequestVM.errorMessage != nil)
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(chatRequestVM.errorMessage ?? "")
        }
    }
}

#if DEBUG
    #Preview {
        MeetUpRequestDetailsView(
            request: (mockChatRequestDocument as? ChatRequestDocument)!
        )
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
    }
#endif
