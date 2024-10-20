//
//  AppwriteService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import Foundation

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

    let databaseId = "orbit"
    let collectionId = "users"
    let bucketId = "userAssets"
    //    var functionId = "YOUR_FUNCTION_ID"
    //    var executionId = ""
    //    var userId = ""
    //    var userEmail = ""
    //    var documentId = ""
    //    var fileId = ""

    static let shared = AppwriteService()

    func uploadImage(base64Image: String, completion: @escaping (Result<String, Error>) -> Void) {
           // Logic to upload image to Appwrite or any other service
           // On success, return the file URL or ID
           completion(.success("https://example.com/uploaded_image.jpg"))  // Example success response
       }
    
    
    init() {

        client = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject("67017126001e334dd053")
            .setSelfSigned(true)  // For self signed certificates, only use for development

        account = Account(client)
        databases = Databases(client)
        storage = Storage(client)
        realtime = Realtime(client)

    }
}
