//
//  MeetupRequestService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//
import Appwrite
import Foundation
import JSONCodable

protocol MeetupRequestServiceProtocol {
    func createMeetup(_ meetup: MeetupRequestModel) async throws
        -> MeetupRequestDocument
    func getMeetup(_ meetupId: String) async throws -> MeetupRequestDocument?
    func updateMeetup(meetupId: String, updatedMeetup: MeetupRequestModel)
        async throws -> MeetupRequestDocument?
    func deleteMeetup(_ meetupId: String) async throws
    func listMeetups(queries: [String]?) async throws -> [MeetupRequestDocument]
}

class MeetupRequestService: MeetupRequestServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared
    private let collectionId = "meetupRequests"

    // Create a new meetup request
    func createMeetup(_ meetup: MeetupRequestModel) async throws
        -> MeetupRequestDocument
    {
        let document = try await appwriteService.databases.createDocument<
            MeetupRequestModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            documentId: ID.unique(),
            data: meetup.toJson(),
            permissions: nil,  // [Appwrite.Permission.write(Role.user(meetup.createdBy.accountId))],
            nestedType: MeetupRequestModel.self
        )
        return document
    }

    // Fetch a specific meetup by its document ID
    func getMeetup(_ meetupId: String) async throws -> MeetupRequestDocument? {
        do {
            let document = try await appwriteService.databases.getDocument<
                MeetupRequestModel
            >(
                databaseId: appwriteService.databaseId,
                collectionId: collectionId,
                documentId: meetupId,
                queries: nil,
                nestedType: MeetupRequestModel.self
            )
            return document
        } catch {
            throw NSError(domain: "Meetup not found", code: 404, userInfo: nil)
        }
    }

    // Update an existing meetup request
    func updateMeetup(meetupId: String, updatedMeetup: MeetupRequestModel)
        async throws -> MeetupRequestDocument?
    {
        do {
            let updatedDocument = try await appwriteService.databases
                .updateDocument<MeetupRequestModel>(
                    databaseId: appwriteService.databaseId,
                    collectionId: collectionId,
                    documentId: meetupId,
                    data: updatedMeetup.toJson(),
                    permissions: nil,
                    nestedType: MeetupRequestModel.self
                )
            return updatedDocument
        } catch {
            throw NSError(
                domain: "Failed to update meetup", code: 500, userInfo: nil)
        }
    }

    // Delete a meetup request
    func deleteMeetup(_ meetupId: String) async throws {
        do {
            try await appwriteService.databases.deleteDocument(
                databaseId: appwriteService.databaseId,
                collectionId: collectionId,
                documentId: meetupId
            )
        } catch {
            throw NSError(
                domain: "Failed to delete meetup", code: 500, userInfo: nil)
        }
    }

    // Fetch all meetups with optional query parameters
    func listMeetups(queries: [String]? = nil) async throws
        -> [MeetupRequestDocument]
    {
        let documents = try await appwriteService.databases.listDocuments<
            MeetupRequestModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: collectionId,
            queries: queries,
            nestedType: MeetupRequestModel.self
        )
        return documents.documents
    }
}
