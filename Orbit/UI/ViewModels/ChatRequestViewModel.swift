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

    private let chatRequestService: ChatRequestServiceProtocol

    init(chatRequestService: ChatRequestServiceProtocol = ChatRequestService())
    {
        self.chatRequestService = chatRequestService
    }

    // Send a meet-up request
    @MainActor
    func sendMeetUpRequest(request: ChatRequestModel) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let requestDoc = try await chatRequestService.sendMeetUpRequest(
                request)
            print(requestDoc)
            self.requests.append(requestDoc)
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
    func fetchMeetUpRequest(requestId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let request = try await chatRequestService.getMeetUpRequest(
                requestId: requestId)
            {
                self.requests.append(request)
            } else {
                self.errorMessage = "Meet-up request not found."
            }
        } catch {
            self.errorMessage =
                "Error fetching meet-up request: \(error.localizedDescription)"
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
