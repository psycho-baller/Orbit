//
//  ChatRequestServiceProtocol.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-14.
//

import Appwrite
import Foundation

protocol ChatRequestServiceProtocol {
    func getMeetUpRequests(userId: String, limit: Int?, offset: Int?) async throws -> [ChatRequestDocument]
    func getMeetUpRequest(requestId: String) async throws -> ChatRequestDocument?
    func sendMeetUpRequest(_ request: ChatRequestModel) async throws -> ChatRequestDocument
    func updateMeetUpRequestStatus(requestId: String, status: ChatRequestModel.RequestStatus) async throws -> ChatRequestDocument
}

class ChatRequestService: ChatRequestServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared
    private let collectionId: String = "chatRequests"

    // Send a meet-up request with ChatRequestModel as an argument
    func sendMeetUpRequest(_ request: ChatRequestModel) async throws
        -> ChatRequestDocument
    {
        // Check if there's already a pending request for this receiver
        let existingRequests = try await getMeetUpRequests(userId: request.receiverAccountId)
        let hasPendingRequest = existingRequests.contains { existing in
            existing.data.senderAccountId == request.senderAccountId &&
            existing.data.status == .pending
        }
        
        if hasPendingRequest {
            throw NSError(
                domain: "ChatRequestService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "You already have a pending request with this user."]
            )
        }
        
        let response = try await appwriteService.databases.createDocument<ChatRequestModel>(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: ID.unique(),
            data: request.toJson(),
            permissions: nil,
            nestedType: ChatRequestModel.self
                //            [
                //                .read(Role.user(request.receiverId)),  // Receiver can view the request
                //                .update(Role.user(request.receiverId)),  // Receiver can respond to the request
                //                .read(Role.user(request.senderId)),  // Sender can view the request
                //                .update(Role.user(request.senderId))  // Sender can receive updates
                //            ]
        )
        
        print("Created meet-up request: \(response.data)")
        
        return response
    }

    // Retrieve a meet-up request by its ID
    func getMeetUpRequest(requestId: String) async throws
        -> ChatRequestDocument?
    {
        return try await appwriteService.databases.getDocument<
            ChatRequestModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: requestId,
            queries: [],
            nestedType: ChatRequestModel.self
        )
    }

    // Respond to a meet-up request (approve/decline)
    func updateMeetUpRequestStatus(requestId: String, status: ChatRequestModel.RequestStatus) async throws -> ChatRequestDocument {
        let updatedData = ["status": status.rawValue]
        
        return try await appwriteService.databases.updateDocument(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: requestId,
            data: updatedData,
            permissions: nil,
            nestedType: ChatRequestModel.self
        )
    }

    // Get meetup requests for a user
    func getMeetUpRequests(
        userId: String, limit: Int? = nil, offset: Int? = nil
    ) async throws -> [ChatRequestDocument] {
        let receiverQuery = Query.equal("receiverAccountId", value: userId)
        let senderQuery = Query.equal("senderAccountId", value: userId)
        let statusQuery = Query.equal("status", value: "pending")
        let userQuery = Query.or([receiverQuery, senderQuery])
        
        let response = try await appwriteService.databases.listDocuments<ChatRequestModel>(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            queries: [userQuery, statusQuery],
            nestedType: ChatRequestModel.self
        )
        print("Service fetched \(response.documents.count) documents for user \(userId)")
        return response.documents
    }
}






