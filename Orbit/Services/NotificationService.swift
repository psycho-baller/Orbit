//
//  NotificationService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-22.
//

import Foundation

protocol NotificationServiceProtocol {
<<<<<<< HEAD
    func sendPushNotification(to accountId: String, title: String, body: String)
=======
    func sendPushNotification(
        to accountIds: [String], title: String, body: String,
        data: [String: Any])
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        async throws

}

class NotificationService: NotificationServiceProtocol {
    private var appwriteService: AppwriteService
    //    private var messagingService: MessagingService

    init(appwriteService: AppwriteService = .shared) {
        self.appwriteService = appwriteService
        //        self.messagingService = appwriteService.messaging
    }

<<<<<<< HEAD
    func sendPushNotification(to accountId: String, title: String, body: String)
=======
    func sendPushNotification(
        to accountIds: [String], title: String, body: String,
        data: [String: Any]
    )
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        async throws
    {
        // Construct the json body for the push notification
        let body: [String: Any] = [
            "message": [
                "title": title,
                "body": body,
            ],
<<<<<<< HEAD
            "data": [
                "userIds": [accountId]
            ],
            // "DeviceToken": "",
=======
            "userIds": accountIds,
            "data": data,
                // "DeviceToken": "",
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        ]

        // Convert the dictionary to JSON data
        if let jsonBody = try? JSONSerialization.data(
            withJSONObject: body, options: .prettyPrinted)
        {
            // Convert JSON data to a string
            if let stringBody = String(data: jsonBody, encoding: .utf8) {
                print("JSON String: \(stringBody)")
                do {
                    // Call the Appwrite backend function to send the push notification
                    let response = try await appwriteService.functions
                        .createExecution(
                            functionId: "push-notif",
                            body: stringBody,
                            async: true
                        )
                    print("Notification sent successfully: \(response.status)")
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
