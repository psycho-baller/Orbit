//
//  ChatRequestServiceProtocol.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-14.
//

import Appwrite
import Foundation

protocol ChatRequestServiceProtocol {
    func sendMeetUpRequest(_ request: ChatRequestModel) async throws
        -> ChatRequestDocument
    func getMeetUpRequest(requestId: String) async throws
        -> ChatRequestDocument?
    func respondToMeetUpRequest(
        requestId: String, response: ChatRequestModel.RequestStatus
    ) async throws -> ChatRequestDocument?
}

class ChatRequestService: ChatRequestServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared
    private let collectionId: String = "chatRequests"

    // Send a meet-up request with ChatRequestModel as an argument
    func sendMeetUpRequest(_ request: ChatRequestModel) async throws
        -> ChatRequestDocument
    {
        let document = try await appwriteService.databases.createDocument<
            ChatRequestModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: request.id,
            data: request,
            permissions: nil,
            nestedType: ChatRequestModel.self
                //            [
                //                .read(Role.user(request.receiverId)),  // Receiver can view the request
                //                .update(Role.user(request.receiverId)),  // Receiver can respond to the request
                //                .read(Role.user(request.senderId)),  // Sender can view the request
                //                .update(Role.user(request.senderId))  // Sender can receive updates
                //            ]
        )

        return document
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
    func respondToMeetUpRequest(
        requestId: String, response: ChatRequestModel.RequestStatus
    ) async throws -> ChatRequestDocument? {
        let updatedData = ["status": response.rawValue]

        let document = try await appwriteService.databases.updateDocument<
            ChatRequestModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: requestId,
            data: updatedData,
            permissions: nil,
            nestedType: ChatRequestModel.self
        )

        return document
    }
}
