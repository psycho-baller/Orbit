//
//  Shared.swift
//  orbit
//
//  Created by Rami Maalouf on 2024-11-22.
//
@preconcurrency import Appwrite
import Foundation

@MainActor
public let processInfo = ProcessInfo.processInfo
@MainActor
public let PROJECT_ID = "67017126001e334dd053"
@MainActor
public let APPWRITE_API_KEY = processInfo.environment["APPWRITE_API_KEY"] ?? ""
@MainActor
public let DATABASE_ID = "orbit"
@MainActor
public let COLLECTION_ID = "users"

@MainActor
public let client: Client = {
    print("Initializing Appwrite client... \(APPWRITE_API_KEY)")
    let client = Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject(PROJECT_ID)
        .setKey(APPWRITE_API_KEY)
    return client
}()

@MainActor
public let databases = Databases(client)

@MainActor
public let messaging = Messaging(client)

@MainActor
public let users = Users(client)
