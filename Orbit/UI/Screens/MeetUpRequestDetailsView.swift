//
//  MeetUpRequestDetailsView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-15.
//

import SwiftUI

struct MeetUpRequestDetailsView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
<<<<<<< HEAD
    //    @EnvironmentObject var messagingVM: MessagingViewModel
=======
    @EnvironmentObject var userVM: UserViewModel
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
    @Environment(\.dismiss) var dismiss
    var request: ChatRequestDocument

    var body: some View {
        VStack {
<<<<<<< HEAD
            Text("Meet-up request from \(request.data.senderAccountId)")
                .font(.headline)
                .padding()
=======
            Text(
                "Meet-up request from \(userVM.getUserName(from: request.data.senderAccountId))"
            )
            .font(.headline)
            .padding()
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac

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
<<<<<<< HEAD
=======

#if DEBUG
    #Preview {
        MeetUpRequestDetailsView(
            request: (mockChatRequestDocument as? ChatRequestDocument)!
        )
        .environmentObject(ChatRequestViewModel.mock())
        .environmentObject(UserViewModel.mock())
    }
#endif
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
