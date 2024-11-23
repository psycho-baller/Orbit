//
//  NotificationService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-22.
//

import Foundation

class NotificationService {
    private var appwriteService: AppwriteService
    //    private var messagingService: MessagingService

    init(appwriteService: AppwriteService = .shared) {
        self.appwriteService = appwriteService
        //        self.messagingService = appwriteService.messaging
    }

    func sendPushNotification(to accountId: String, title: String, body: String)
        async throws
    {
        // Construct the json body for the push notification
        let body: [String: Any] = [
            "message": [
                "title": title,
                "body": body,
            ],
            "data": [
                "userIds": [accountId]
            ],
            "DeviceToken": "ass",
        ]

        // Convert the dictionary to JSON data
        if let jsonBody = try? JSONSerialization.data(
            withJSONObject: body, options: .prettyPrinted)
        {
            // Convert JSON data to a string
            if let stringBody = String(data: jsonBody, encoding: .utf8) {
                print("JSON String: \(stringBody)")
                do {
                    // Call the Appwrite messaging service to send the notification
                    let response = try await appwriteService.functions
                        .createExecution(
                            functionId: "push-notif",
                            body: stringBody,
                            async: true,
                            method: .pOST,
                            headers: [:]
                        )
                    print("Notification sent successfully: \(response)")
                } catch {
                    throw NSError(
                        domain: "NotificationService", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Failed to send push notification: \(error.localizedDescription)"
                        ])
                }
            } else {
                print("Failed to convert JSON data to String.")
            }
        } else {
            print("Failed to serialize JSON object.")
        }
    }
}
