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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @State private var message = ""
    @State private var isKeyboardVisible = false

    var body: some View {
        VStack(spacing: 10) {
            // Title and interests section
            VStack {
                Text("Request to Chat with \(receiver.name)")
                    .font(.title)
                    .padding()
                    .foregroundColor(ColorPalette.text(for: colorScheme))

                Text(
                    "Interests: \(receiver.interests?.joined(separator: ", ") ?? "No interests available")"
                )
                .foregroundColor(ColorPalette.text(for: colorScheme))

                Spacer()  // This pushes the text field and button down to the bottom
            }

            // Bottom section with TextField and Button
            // Bottom section with TextField and Button inside a translucent background with rounded top
            HStack(spacing: 10) {
                TextField(
                    "Enter your message...", text: $message
                )
                .padding([.leading, .vertical])
                .font(.title2)

                if let senderAccountId = sender?.accountId {
                    Button(action: {
                        let request = ChatRequestModel(
                            senderAccountId: senderAccountId,
                            receiverAccountId: receiver.accountId,
                            message: message
                        )
                        Task {
                            await chatRequestVM.sendMeetUpRequest(
                                request: request, from: sender?.name)
                            dismiss()
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(
                                ColorPalette.text(for: colorScheme)
                            )
                            .font(.title3)
                    }
                    .padding(.trailing)
                }
            }
            .padding([.leading, .trailing])
            .padding(.bottom, isKeyboardVisible ? 0 : 16)
            .background(.regularMaterial)  // Translucent background
            .clipShape(
                RoundedCornerShape(corners: [.topLeft, .topRight], radius: 30))
        }
        .onAppear {
            // Subscribe to keyboard notifications
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification, object: nil,
                queue: .main
            ) { _ in
                self.isKeyboardVisible = true
            }

            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification, object: nil,
                queue: .main
            ) { _ in
                self.isKeyboardVisible = false
            }
        }
        .onDisappear {
            // Remove observers when view disappears
            NotificationCenter.default.removeObserver(
                self, name: UIResponder.keyboardWillShowNotification,
                object: nil)
            NotificationCenter.default.removeObserver(
                self, name: UIResponder.keyboardWillHideNotification,
                object: nil)
        }
        .ignoresSafeArea(edges: isKeyboardVisible ? [] : [.bottom])  // Conditionally apply ignoresSafeArea
        .padding(.top)  // Optional, to give a bit of space at the top
        //        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //        .cornerRadius(15)
        .alert(
            "Error", isPresented: .constant(chatRequestVM.errorMessage != nil)
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(chatRequestVM.errorMessage ?? "")
        }
    }
}

#Preview {
    let sender = UserModel(
        accountId: "1", name: "John", interests: ["Swift", "iOS", "Coding"],
        latitude: 40.7127, longitude: -74.0059, isInterestedToMeet: true,
        conversations: ["1", "2", "3"], currentAreaId: "1")
    let receiver = UserModel(
        accountId: "2", name: "Jane", interests: ["Swift", "iOS", "Coding"],
        latitude: 40.7127, longitude: -74.0059,
        isInterestedToMeet: true,
        conversations: ["1", "2", "3"], currentAreaId: "1")
    ChatRequestView(sender: sender, receiver: receiver)
        .environmentObject(ChatRequestViewModel.mock())
}
