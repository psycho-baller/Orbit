//
//  AppDelegate.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-21.
//

import SwiftUI
import UIKit
import UserNotifications
import os

class AppDelegate: NSObject, UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{
    let logger = Logger(
        subsystem: "com.cpsc575.orbit.pushnotifications",
        category: "AppDelegate")

    let appState = AppState()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logger.info("App launched. Setting up push notification registration.")

        // Set the notification center delegate
        UNUserNotificationCenter.current().delegate = self

        // Request notification permissions
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { granted, error in
            if let error = error {
                self.logger.error(
                    "Failed to request notification authorization: \(error.localizedDescription)"
                )
            } else {
                self.logger.info(
                    "Notification authorization granted: \(granted)")
            }

            DispatchQueue.main.async {
                if granted {
                    application.registerForRemoteNotifications()
                    self.logger.info("Registered for remote notifications.")
                } else {
                    self.logger.warning("User denied notification permissions.")
                }
            }
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey: "apnsToken")
        logger.info(
            "Successfully registered for remote notifications. Device token: \(token)"
        )
        print("Device token: \(token)")  // Optional: For console output
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        logger.error(
            "Failed to register for remote notifications: \(error.localizedDescription)"
        )
        print(
            "Failed to register for remote notifications: \(error.localizedDescription)"
        )
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo, separator: "\n")
        if // let targetScreen = userInfo["targetScreen"] as? String,
        let requestId = userInfo["requestId"] as? String {  // Assume requestId is passed in the payload
            DispatchQueue.main.async {
                // self.appState.targetScreen = targetScreen
                self.appState.selectedRequestId = requestId
            }
        }
        completionHandler()
    }
}
