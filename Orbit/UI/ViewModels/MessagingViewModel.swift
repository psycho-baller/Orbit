//
//  MessagingViewModel.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

@preconcurrency import Appwrite
import Appwrite
import CoreLocation
import Foundation
import SwiftUI

class MessagingViewModel: ObservableObject, PreciseLocationManagerDelegate {
    static let shared = MessagingViewModel()
    private var messagingService: MessagingServiceProtocol = MessagingService()
    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()
    private var subscription: RealtimeSubscription?
    @Published var conversations: [ConversationDetailModel] = []
    @Published var messages: [MessageDocument] = []
    @Published var lastMessageId: String? = nil
    @Published var currentLocation: CLLocationCoordinate2D?
    var lastMessageld: Binding<String?> {
        Binding(
            get: { self.lastMessageId },
            set: { self.lastMessageId = $0 }
        )
    }

    func didUpdateLocation(latitude: Double, longitude: Double) {
        print(
            "MessagingViewModel - didUpdateLocation: Received location update - Latitude: \(latitude), Longitude: \(longitude)."
        )
        self.currentLocation = CLLocationCoordinate2D(
            latitude: latitude, longitude: longitude)
    }

    let coordinateFormat = "<[LOC|{latitude},{longitude}]>"

    func encodeCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        let formattedString =
            coordinateFormat
            .replacingOccurrences(
                of: "{latitude}", with: "\(coordinate.latitude)"
            )
            .replacingOccurrences(
                of: "{longitude}", with: "\(coordinate.longitude)")
        return formattedString
    }

    func decodeCoordinate(from string: String) -> CLLocationCoordinate2D? {
        // Create a regular expression pattern based on the global format
        let latitudePattern = "(-?\\d+\\.\\d+)"
        let longitudePattern = "(-?\\d+\\.\\d+)"

        // Escape special regex characters in the format and replace placeholders with patterns
        let escapedFormat = NSRegularExpression.escapedPattern(
            for: coordinateFormat
        )
        .replacingOccurrences(of: "\\{latitude\\}", with: latitudePattern)
        .replacingOccurrences(of: "\\{longitude\\}", with: longitudePattern)

        let pattern = "^" + escapedFormat + "$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = string as NSString
        let results = regex?.matches(
            in: string, range: NSRange(location: 0, length: nsString.length))

        guard let match = results?.first else { return nil }

        // Extract latitude and longitude from the match
        let latitudeRange = match.range(at: 1)
        let longitudeRange = match.range(at: 2)

        guard let latitude = Double(nsString.substring(with: latitudeRange)),
            let longitude = Double(nsString.substring(with: longitudeRange))
        else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func isValidCoordinateFormat(_ string: String) -> Bool {
        // Create a regular expression pattern based on the global format
        let latitudePattern = "(-?\\d+\\.\\d+)"
        let longitudePattern = "(-?\\d+\\.\\d+)"

        // Escape special regex characters in the format and replace placeholders with patterns
        let escapedFormat = NSRegularExpression.escapedPattern(
            for: coordinateFormat
        )
        .replacingOccurrences(of: "\\{latitude\\}", with: latitudePattern)
        .replacingOccurrences(of: "\\{longitude\\}", with: longitudePattern)

        let pattern = "^" + escapedFormat + "$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: string.utf16.count)

        return regex?.firstMatch(in: string, options: [], range: range) != nil
    }

    @MainActor
    func getConversations(_ accountId: String) async -> [String] {
        do {
            if let userModel = try await userManagementService.getUser(
                accountId)
            {
                if let conversations = userModel.data.conversations {
                    return conversations
                }
            }
            throw NSError(domain: "UsersNotFound: \"\(accountId)\"", code: 404)
        } catch {
            print(
                "MessagingViewModel - getConversations failed \(error.localizedDescription)"
            )
            return []
        }
    }

    @MainActor
    func createConversation(_ participants: [String]) async -> String? {
        do {
            print(
                "DEBUG: Starting conversation creation for participants: \(participants)"
            )
            let conversationData = ConversationModel(participants: participants)
            let conversationEntry =
                try await messagingService.findOrCreateConversation(
                    conversationData)
            print(
                "DEBUG: Created conversation entry with ID: \(conversationEntry.id)"
            )

            // Update users' conversation lists
            for accountId in participants {
                print(
                    "DEBUG: Updating conversation list for user: \(accountId)")
                if let userModel = try await userManagementService.getUser(
                    accountId)
                {
                    var conversations = userModel.data.conversations ?? []
                    if !conversations.contains(conversationEntry.id) {
                        conversations.append(conversationEntry.id)
                        let updatedUser = userModel.data.update(
                            conversations: conversations)
                        try await userManagementService.updateUser(
                            accountId: accountId, updatedUser: updatedUser)
                        print(
                            "DEBUG: Updated user \(accountId) with conversations: \(conversations)"
                        )
                    }
                }
            }

            // Create initial system message
            let systemMessage = MessageModel(
                conversationId: conversationEntry.id,
                senderAccountId: "system",
                message: "Conversation started"
            )
            _ = try await messagingService.createMessage(systemMessage)
            print("DEBUG: Created initial system message")

            // Force refresh conversations for both participants
            for accountId in participants {
                let conversationDetails = await getConversationDetails(
                    accountId)
                if accountId == participants[0] {  // Only update UI for current user
                    DispatchQueue.main.async {
                        self.conversations = conversationDetails
                        print(
                            "DEBUG: Updated conversations list with \(conversationDetails.count) conversations"
                        )
                    }
                }
            }

            return conversationEntry.id
        } catch {
            print("DEBUG: Failed to create conversation: \(error)")
            return nil
        }
    }

    @MainActor
    func getMessages(_ conversationId: String, _ numOfMessages: Int = 100) async
        -> [MessageDocument]
    {
        print("Loading messages for conversation ID: \(conversationId)")
        do {
            messages = try await messagingService.getMessages(
                conversationId, numOfMessages)
            if let lastMessage = messages.last {
                lastMessageId = lastMessage.id
            }
            return messages
        } catch {
            print(
                "MessagingViewModel - createMessage failed \(error.localizedDescription)"
            )
            return []
        }
    }

    @MainActor
    func getConversationDetails(_ accountId: String) async
        -> [ConversationDetailModel]
    {
        print("Getting conversations for user: \(accountId)")

        let conversationIds = await getConversations(accountId)
        print("Fetched conversation IDs: \(conversationIds)")

        let conversationDetails = await withTaskGroup(
            of: ConversationDetailModel?.self
        ) { group in
            for conversationId in conversationIds {
                group.addTask {
                    await self.fetchConversationDetail(
                        accountId: accountId, conversationId: conversationId)
                }
            }

            var results: [ConversationDetailModel] = []
            for await detail in group {
                if let detail = detail {
                    results.append(detail)
                }
            }
            return results
        }
        return conversationDetails.sorted { $0.timestamp > $1.timestamp }
    }

    @MainActor
    private func fetchConversationDetail(
        accountId: String, conversationId: String
    ) async -> ConversationDetailModel? {
        do {
            print(
                "DEBUG: Fetching conversation detail for ID: \(conversationId)")

            guard try await messagingService.conversationExists(conversationId)
            else {
                print("DEBUG: Conversation \(conversationId) no longer exists")
                return nil
            }

            let participants = try await messagingService.getParticipants(
                for: conversationId)
            print("DEBUG: Found participants: \(participants)")

            guard
                let otherParticipantId = participants.first(where: {
                    $0 != accountId
                })
            else {
                print("DEBUG: Could not find other participant")
                return nil
            }

            let messagerName = await getParticipantName(otherParticipantId)
            print("DEBUG: Got participant name: \(messagerName)")

            let messages = try await messagingService.getMessages(
                conversationId, 100)
            print("DEBUG: Found \(messages.count) messages")

            return ConversationDetailModel(
                id: conversationId,
                messagerName: messagerName,
                lastMessage: messages.last?.data.message ?? "No messages yet",
                timestamp: messages.last.map { formatTimestamp($0.createdAt) }
                    ?? "Just now",
                isRead: messages.last?.data.isRead ?? true,
                lastSenderId: messages.last?.data.senderAccountId ?? ""
            )
        } catch {
            print("DEBUG: Error fetching conversation detail: \(error)")
            return nil
        }
    }

    private func getParticipantName(_ participantId: String) async -> String {
        do {
            if let user = try await userManagementService.getUser(participantId)
            {
                return user.data.name
            }
        } catch {
            print(
                "Failed to get participant name for ID \(participantId): \(error)"
            )
        }
        return "Unknown"
    }

    func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeZone = TimeZone.current
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }

        return "Unknown"
    }

    @MainActor
    func subscribeToMessages(
        conversationId: String,
        onNewMessage: @escaping (MessageDocument) -> Void
    ) async {
        do {
            try await messagingService.subscribeToMessages(
                conversationId: conversationId,
                onNewMessage: { newMessage in
                    DispatchQueue.main.async {
                        onNewMessage(newMessage)  // Safely call the optional closure
                    }
                }
            )
            print(
                "MessagingViewModel - Subscribed to real-time messages for conversation: \(conversationId)"
            )

        } catch {
            print(
                "MessagingViewModel - Failed to subscribe to real-time messages: \(error.localizedDescription)"
            )
        }

    }

    @MainActor
    func unsubscribeFromMessages() async {
        await messagingService.unsubscribeFromMessages()
    }

    @MainActor
    func subscribeToInboxMessages(
        onNewMessage: @escaping (MessageDocument) -> Void
    ) async {
        do {
            try await messagingService.subscribeToInboxMessages(
                onNewMessage: { newMessage in
                    DispatchQueue.main.async {
                        onNewMessage(newMessage)  // Safely call the optional closure
                    }
                }
            )
            print(
                "MessagingViewModel - Subscribed to real-time messages for conversation Inbox"
            )

        } catch {
            print(
                "MessagingViewModel - Failed to subscribe to real-time messages for Inbox: \(error.localizedDescription)"
            )
        }

    }

    @MainActor
    func unsubscribeFromInboxMessages() async {
        await messagingService.unsubscribeFromInboxMessages()
    }

    /// Initializes the inbox: Fetches conversations and subscribes to new messages
    @MainActor
    func initializeInbox(
        for userId: String?,
        completion: @escaping ([ConversationDetailModel]) -> Void
    ) async {
        guard let userId = userId else {
            print("DEBUG: Initialize inbox failed - User ID not found")
            return
        }

        print("DEBUG: Initializing inbox for user: \(userId)")

        // Get user's conversation list directly
        if let userModel = try? await userManagementService.getUser(userId) {
            print(
                "DEBUG: User conversations from database: \(userModel.data.conversations ?? [])"
            )
        }

        let fetchedConversations = await getConversationDetails(userId)
        print(
            "DEBUG: Fetched conversation details: \(fetchedConversations.map { $0.id })"
        )

        DispatchQueue.main.async {
            self.conversations = fetchedConversations
            print(
                "DEBUG: Updated conversations in ViewModel for \(userId): \(self.conversations.count)"
            )
            completion(fetchedConversations)
        }

        await subscribeToInboxMessages(onNewMessage: { newMessage in
            print(
                "DEBUG: Received new message: \(newMessage.id) for conversation: \(newMessage.data.conversationId)"
            )
        })
    }

    @MainActor
    func markMessagesRead(conversationId: String, currentAccountId: String)
        async
    {
        do {
            try await messagingService.markMessagesRead(
                conversationId: conversationId,
                currentAccountId: currentAccountId)
            print(
                "MessagingViewModel - marked all messages as read in conversation \(conversationId)"
            )
        } catch {
            print(
                "MessagingViewModel - failed to mark messages as read: \(error.localizedDescription)"
            )
        }
    }

    @MainActor
    func createMessage(
        conversationId: String, senderAccountId: String, message: String
    ) async {
        do {
            let messageData = MessageModel(
                conversationId: conversationId,
                senderAccountId: senderAccountId,
                message: message,
                isRead: false
            )
            let messageDoc = try await messagingService.createMessage(
                messageData)
            print(
                "DEBUG: Created message: \(messageDoc.id) in conversation: \(conversationId)"
            )

            // Force refresh the conversation details
            await initializeInbox(for: senderAccountId) { _ in }
        } catch {
            print(
                "MessagingViewModel - createMessage failed: \(error.localizedDescription)"
            )
        }
    }

}
