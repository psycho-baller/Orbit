//
//  NotificationService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-14.
//

import Appwrite
import SwiftUI
import UserNotifications

class NotificationService: NSObject, ObservableObject {
    @Published var deviceToken: String?

    private let appwriteService: AppwriteService = AppwriteService.shared

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound, .badge,
        ]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print(
                    "Failed to request authorization for notifications: \(error)"
                )
            }
        }
    }

    func registerDeviceWithAppwrite(token: String) async {
        do {
            let subscriber = try await appwriteService.messaging
                .createSubscriber(topicId: "", subscriberId: "", targetId: "")
        } catch {
            print("Failed to register device with Appwrite: \(error)")

        }
    }

    func unregisterDeviceWithAppwrite() async {
        do {
            let subscriber = try await appwriteService.messaging
                .deleteSubscriber(topicId: "", subscriberId: "")
        } catch {
            print("Failed to unregister device with Appwrite: \(error)")
        }
    }
}

// MARK: - UIApplicationDelegate Methods as Extension for Device Token
extension NotificationService: UNUserNotificationCenterDelegate,
    UIApplicationDelegate
{
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }
            .joined()
        self.deviceToken = tokenString
        print("Device Token: \(tokenString)")
        Task {
            await registerDeviceWithAppwrite(token: tokenString)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }
}
