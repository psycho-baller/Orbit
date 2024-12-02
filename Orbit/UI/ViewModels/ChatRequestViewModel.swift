//
//  ChatRequestViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-14.
//

import Foundation
import SwiftUI

class ChatRequestViewModel: ObservableObject {
    @Published var requests: [ChatRequestDocument] = [] {
        didSet {  //Called when requests is modified
            updateFilteredRequests()
        }
    }
    @Published var incomingRequests: [ChatRequestDocument] = []
    @Published var outgoingRequests: [ChatRequestDocument] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var selectedRequest: ChatRequestDocument?
    @Published var newConversationId: String?

    private let chatRequestService: ChatRequestServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let messagingService: MessagingServiceProtocol
    private let userManagementService: UserManagementServiceProtocol
    private var activeUserId: String?

    init(
        chatRequestService: ChatRequestServiceProtocol = ChatRequestService(),
        notificationService: NotificationServiceProtocol =
            NotificationService(),
        messagingService: MessagingServiceProtocol = MessagingService(),
        userManagementService: UserManagementServiceProtocol =
            UserManagementService()

    ) {
        self.chatRequestService = chatRequestService
        self.notificationService = notificationService
        self.messagingService = messagingService
        self.userManagementService = userManagementService
    }

    private func updateFilteredRequests() {
        guard let userId = activeUserId else { return }
        incomingRequests = requests.filter { request in
            request.data.receiverAccountId == userId
        }
        outgoingRequests = requests.filter { request in
            request.data.senderAccountId == userId
        }
    }

    @MainActor
    func fetchRequestsForUser(userId: String) async {
        do {
            self.activeUserId = userId
            let fetchedRequestsDocuments =
                try await chatRequestService.getMeetUpRequests(
                    userId: userId, limit: nil, offset: nil)
            DispatchQueue.main.async {
                self.requests = fetchedRequestsDocuments
            }
        } catch {
            self.errorMessage =
                "Failed to load requests: \(error.localizedDescription)"
        }
    }

    // MARK: - Send a Meet-Up Request

    @MainActor
    func sendMeetUpRequest(request: ChatRequestModel, from senderName: String?)
        async
    {
        do {
            print("Sending meet-up request...")
            let requestDoc = try await chatRequestService.sendMeetUpRequest(
                request)
            print("Created meet-up request: \(requestDoc)")

            // Add to sent requests tracking
            //            markRequestSent(to: request.receiverAccountId)
            self.requests.append(requestDoc)

            // Send push notification
            try await notificationService.sendPushNotification(
                to: [request.receiverAccountId],
                title:
                    "New meet-up request\(senderName.map { " from \($0)" } ?? "")",
                body: request.message,
                data: [
                    "requestId": requestDoc.id,
                    "type": "newMeetupRequest",
                ]
            )
        } catch {
            self.errorMessage =
                "Failed to send meet-up request: \(error.localizedDescription)"
        }
    }

    func hasSentRequest(to accountId: String) -> Bool {
        return outgoingRequests.contains {
            $0.data.receiverAccountId == accountId
        }
    }

    // MARK: - Fetch a Specific Meet-Up Request

    @MainActor
    func getMeetUpRequest(requestId: String) async -> ChatRequestDocument? {
        isLoading = true
        defer { isLoading = false }

        do {
            if let request = try await chatRequestService.getMeetUpRequest(
                requestId: requestId)
            {
                return request
            } else {
                self.errorMessage = "Meet-up request not found."
                throw NSError(domain: "ChatRequestViewModel", code: 404)
            }
        } catch {
            self.errorMessage =
                "Error fetching meet-up request: \(error.localizedDescription)"
            return nil
        }
    }

    // MARK: - Respond to a Meet-Up Request

    @MainActor
    func respondToMeetUpRequest(
        requestId: String, response: ChatRequestModel.RequestStatus
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let updatedRequest =
                try await chatRequestService.updateMeetUpRequestStatus(
                    requestId: requestId,
                    status: response
                )

            if let index = requests.firstIndex(where: {
                $0.id == requestId
            }) {
                requests[index] = updatedRequest
            }

            if response == .approved {
                let participants = [
                    updatedRequest.data.senderAccountId,
                    updatedRequest.data.receiverAccountId,
                ]

                // Create conversation and get its ID directly
                let conversationData = ConversationModel(
                    participants: participants
                )
                let conversation =
                    try await messagingService.findOrCreateConversation(
                        conversationData)
                self.newConversationId = conversation.id

                // Update both users' conversation lists
                try await addConversationToUser(
                    userId: participants[0], conversationId: conversation.id)
                try await addConversationToUser(
                    userId: participants[1], conversationId: conversation.id)
                let receiverName =
                    try await userManagementService.getUser(
                        updatedRequest.data.receiverAccountId)?.data.name ?? ""
                try await notificationService.sendPushNotification(
                    to: [updatedRequest.data.senderAccountId],
                    title: "Request Approved!",
                    body:
                        "Your meet-up request to \(receiverName) has been approved. Start chatting!",
                    data: [
                        "conversation": [
                            "id": conversation.id,
                            "receiverName": receiverName,
                            "senderId": updatedRequest.data.senderAccountId,
                        ],
                        "type": "requestApproved",
                    ]
                )
            }
        } catch {
            self.errorMessage =
                "Failed to respond to request: \(error.localizedDescription)"
            print(
                "Error responding to request: \(error.localizedDescription)"
            )
        }
    }

    @MainActor
    func addConversationToUser(
        userId: String, conversationId: String
    ) async throws {
        if let userModel = try await userManagementService.getUser(
            userId)
        {
            var conversations = userModel.data.conversations ?? []
            if !conversations.contains(conversationId) {
                conversations.append(conversationId)
                let updatedUser = userModel.data.update(
                    conversations: conversations)
                try await userManagementService.updateUser(
                    accountId: userId, updatedUser: updatedUser)
                print(
                    "DEBUG: Updated conversations for user \(userId): \(conversations)"
                )
            }
        }

    }
}
// MARK: - Mock for SwiftUI Preview
#if DEBUG
    extension ChatRequestViewModel {
        static func mock() -> ChatRequestViewModel {
            let mockVM = ChatRequestViewModel()
            mockVM.activeUserId = "mockReceiver1"
            mockVM.requests = []
            return mockVM
        }
    }
#endif
