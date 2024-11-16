//
//  AppwriteService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Foundation
import Appwrite
import AppwriteModels

protocol AppwriteServiceProtocol {
    var client: Client { get }
    var account: Account { get }
    var databases: Databases { get }
    var storage: Storage { get }
}

class AppwriteService: AppwriteServiceProtocol {
    let client: Client
    let account: Account
    let databases: Databases
    let storage: Storage
    let realtime: Realtime
    let realtime2: Realtime

    let databaseId = "orbit"
    let collectionId = "users"
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
            .setProject("67017126001e334dd053")
            .setSelfSigned(true)  // For self signed certificates, only use for development

        self.account = Account(client)
        self.databases = Databases(client)
        self.storage = Storage(client)
        self.realtime = Realtime(client)
        self.realtime2 = Realtime(client)

    }
}
