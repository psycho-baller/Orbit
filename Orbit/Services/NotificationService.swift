//
//  NotificationService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-22.
//

import Foundation

class NotificationService {
    private var appwriteService: AppwriteService
    private var messagingService: MessagingService

    init(appwriteService: AppwriteService = .shared) {
        self.appwriteService = appwriteService
        self.messagingService = appwriteService.messaging
    }

    func sendPushNotification(to accountId: String, message: String)
        async throws
    {
        // Construct the payload for the push notification
        let payload: [String: Any] = [
            "accountId": accountId,
            "aps": [
                "alert": [
                    "title": "New Chat Request",
                    "body": message,
                ],
                "sound": "default",
            ],
        ]

        do {
            // Call the Appwrite messaging service to send the notification
            let response = try await messagingService.(
                payload: payload)
            print("Notification sent successfully: \(response)")
        } catch {
            throw NSError(
                domain: "NotificationService", code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to send push notification: \(error.localizedDescription)"
                ])
        }
    }
}
