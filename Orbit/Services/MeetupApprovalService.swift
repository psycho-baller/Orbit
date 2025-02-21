//
//  MeetupApprovalService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//

import Appwrite
import Foundation
import JSONCodable

protocol MeetupApprovalServiceProtocol {
    func createApproval(approval: MeetupApprovalModel) async throws
        -> MeetupApprovalDocument
    func getApproval(approvalId: String) async throws -> MeetupApprovalDocument?
    func deleteApproval(approvalId: String) async throws
    func listApprovals(queries: [String]?) async throws
        -> [MeetupApprovalDocument]
}

class MeetupApprovalService: MeetupApprovalServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared
    private let collectionId = "meetupApprovals"

    // Create an approval
    func createApproval(approval: MeetupApprovalModel) async throws
        -> MeetupApprovalDocument
    {
        let document = try await appwriteService.databases.createDocument<
            MeetupApprovalModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: ID.unique(),
            data: approval.toJson(),
            permissions: nil,  // [Appwrite.Permission.write(Role.user(approval.approvedBy.accountId))],
            nestedType: MeetupApprovalModel.self
        )
        return document
    }

    // Fetch a specific approval
    func getApproval(approvalId: String) async throws -> MeetupApprovalDocument?
    {
        do {
            let document = try await appwriteService.databases.getDocument<
                MeetupApprovalModel
            >(
                databaseId: appwriteService.databaseId,
                collectionId: collectionId,
                documentId: approvalId,
                queries: nil,
                nestedType: MeetupApprovalModel.self
            )
            return document
        } catch {
            throw NSError(
                domain: "Approval not found", code: 404, userInfo: nil)
        }
    }

    // Delete an approval
    func deleteApproval(approvalId: String) async throws {
        do {
            try await appwriteService.databases.deleteDocument(
                databaseId: appwriteService.databaseId,
                collectionId: collectionId,
                documentId: approvalId
            )
        } catch {
            throw NSError(
                domain: "Failed to delete approval", code: 500, userInfo: nil)
        }
    }

    // List all approvals
    func listApprovals(queries: [String]? = nil) async throws
        -> [MeetupApprovalDocument]
    {
        let documents = try await appwriteService.databases.listDocuments<
            MeetupApprovalModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            queries: queries,
            nestedType: MeetupApprovalModel.self
        )
        return documents.documents
    }
}
