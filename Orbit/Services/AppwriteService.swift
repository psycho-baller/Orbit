//
//  AppwriteService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import AppwriteModels
import Foundation

protocol AppwriteServiceProtocol {
    var client: Client { get }
    var account: Account { get }
    var databases: Databases { get }
    var storage: Storage { get }
    var realtime: Realtime { get }
}

class AppwriteService: AppwriteServiceProtocol {
    let client: Client
    let account: Account
    let databases: Databases
    let storage: Storage
    let realtime: Realtime
    //    let realtime2: Realtime
    let messaging: Messaging
    let functions: Functions

    let databaseId = "orbit"
    let bucketId = "userAssets"

    let COLLECTION_ID_MESSAGES = "messages"
    let COLLECTION_ID_CONVERSATIONS = "conversations"
    //    var functionId = "YOUR_FUNCTION_ID"
    //    var executionId = ""
    //    var userId = ""
    //    var userEmail = ""
    //    var documentId = ""
    //    var fileId = ""

    static let shared = AppwriteService()
    init() {

        self.client = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject(APIManager.shared.APPWRITE_PROJECT_ID!)
            .setSelfSigned(true)  // For self signed certificates, only use for development

        self.account = Account(client)
        self.databases = Databases(client)
        self.storage = Storage(client)
        self.realtime = Realtime(client)
        //        self.realtime2 = Realtime(client)
        self.messaging = Messaging(client)
        self.functions = Functions(client)
    }
}
