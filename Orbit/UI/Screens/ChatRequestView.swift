//
//  ChatRequestView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-14.
//

import SwiftUI

// MARK: - Chat Request View
struct ChatRequestView: View {
    let sender: UserModel?
    let receiver: UserModel
    @Environment(\.dismiss) var dismiss
<<<<<<< HEAD
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
=======
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
//    @EnvironmentObject var userVM: UserViewModel
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Request to Chat with \(receiver.name)")
                .font(.title)
                .padding()
                .foregroundColor(ColorPalette.text(for: colorScheme))

            Text(
                "Interests: \(receiver.interests?.joined(separator: ", ") ?? "No interests available")"
            )
            .foregroundColor(ColorPalette.text(for: colorScheme))
            TextField("Enter your message...", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            if let senderAccountId = sender?.accountId {
                Button(action: {
                    let request = ChatRequestModel(
                        senderAccountId: senderAccountId,
                        receiverAccountId: receiver.accountId,
                        message: message
                    )
                    Task {
<<<<<<< HEAD
                        await chatRequestVM.sendMeetUpRequest(request: request)
=======
                        await chatRequestVM.sendMeetUpRequest(request: request, from: sender?.name)
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
                        dismiss()
                    }
                }) {
                    Text("Send Chat Request")
                        .foregroundColor(ColorPalette.text(for: colorScheme))
                        .padding()
                        .background(ColorPalette.button(for: colorScheme))
                        .cornerRadius(10)
                }
            }

            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                    .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.background(for: colorScheme))
        .cornerRadius(15)
        .alert(
            "Error", isPresented: .constant(chatRequestVM.errorMessage != nil)
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(chatRequestVM.errorMessage ?? "")
        }
    }
}
