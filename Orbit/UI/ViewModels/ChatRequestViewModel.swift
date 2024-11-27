//
//  ChatRequestViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-14.
//

import Foundation
import SwiftUI

class ChatRequestViewModel: ObservableObject {
    @Published var requests: [ChatRequestDocument] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published private var sentRequests: Set<String> = []
<<<<<<< HEAD
=======
    @Published var selectedRequest: ChatRequestDocument? = nil
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac

    private let chatRequestService: ChatRequestServiceProtocol
    private let notificationService: NotificationServiceProtocol

    init(
        chatRequestService: ChatRequestServiceProtocol = ChatRequestService(),
        notificationService: NotificationServiceProtocol = NotificationService()
    ) {
        self.chatRequestService = chatRequestService
        self.notificationService = notificationService
    }

    // Send a meet-up request
    @MainActor
<<<<<<< HEAD
    func sendMeetUpRequest(request: ChatRequestModel) async {
=======
    func sendMeetUpRequest(request: ChatRequestModel, from senderName: String?)
        async
    {
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        isLoading = true
        defer { isLoading = false }

        do {
            let requestDoc = try await chatRequestService.sendMeetUpRequest(
                request)
            print(requestDoc)
            self.requests.append(requestDoc)

            try await notificationService.sendPushNotification(
<<<<<<< HEAD
                to: request.receiverAccountId,
                title: "meow",
                body: requestDoc.data.message
=======
                to: [request.receiverAccountId],
                title:
                    "New meet-up request\(senderName.map { " from \($0)" } ?? "")",
                body: requestDoc.data.message,
                data: [
                    "requestId": requestDoc.id
                ]
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
            )

        } catch {
            self.errorMessage =
                "Failed to send meet-up request: \(error.localizedDescription)"
        }
    }

    func hasSentRequest(to accountId: String) -> Bool {
        return sentRequests.contains(accountId)
    }

    func markRequestSent(to accountId: String) {
        sentRequests.insert(accountId)
    }

    // Fetch a specific meet-up request by ID
    @MainActor
<<<<<<< HEAD
    func fetchMeetUpRequest(requestId: String) async {
=======
    func getMeetUpRequest(requestId: String) async -> ChatRequestDocument? {
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        isLoading = true
        defer { isLoading = false }

        do {
            if let request = try await chatRequestService.getMeetUpRequest(
                requestId: requestId)
            {
<<<<<<< HEAD
                self.requests.append(request)
            } else {
                self.errorMessage = "Meet-up request not found."
=======
                return request
            } else {
                self.errorMessage = "Meet-up request not found."
                throw NSError(domain: "ChatRequestViewModel", code: 404)
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
            }
        } catch {
            self.errorMessage =
                "Error fetching meet-up request: \(error.localizedDescription)"
<<<<<<< HEAD
=======
            return nil
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        }
    }

    // Approve or decline a meet-up request
    @MainActor
    func respondToMeetUpRequest(
        requestId: String, response: ChatRequestModel.RequestStatus
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let updatedRequest =
                try await chatRequestService.respondToMeetUpRequest(
                    requestId: requestId, response: response)
            {
                if let index = self.requests.firstIndex(where: {
                    $0.id == updatedRequest.id
                }) {
                    self.requests[index] = updatedRequest
                }
                if response == .approved {
                    print(
                        "Meet-up request approved. Proceed to create conversation in messaging view model."
                    )
                    // Notify MessagingViewModel to create conversation if necessary
                }
            }
        } catch {
            self.errorMessage =
                "Failed to respond to request: \(error.localizedDescription)"
        }
    }

    @MainActor
    func fetchRequestsForUser(userId: String) async {
        do {
            let fetchedRequestsDocuments =
                try await chatRequestService.getMeetUpRequests(
                    userId: userId, limit: nil, offset: nil)
            DispatchQueue.main.async {
                self.requests = fetchedRequestsDocuments
            }
        } catch {
            self.errorMessage =
                "Failed to load requests: \(error.localizedDescription)"
            print("Error loading requests: \(error.localizedDescription)")

        }
    }

}

// MARK: - Mock for SwiftUI Preview
#if DEBUG
    extension ChatRequestViewModel {
        static func mock() -> ChatRequestViewModel {
            let mockVM = ChatRequestViewModel()
            mockVM.requests = []
            return mockVM
        }
    }
#endif
