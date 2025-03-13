//
//  CloudFunctionsService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-03-13.
//

// CloudFunctionsService.swift

import Appwrite
import Foundation

protocol CloudFunctionsServiceProtocol {
    func deleteAccount(accountId: String) async throws -> Bool
}

class CloudFunctionsService: CloudFunctionsServiceProtocol {
    private var functions: Functions

    init(appwriteService: AppwriteService = .shared) {
        self.functions = appwriteService.functions
    }

    func deleteAccount(accountId: String) async throws -> Bool {
        // Validate input
        guard !accountId.isEmpty else {
            throw NSError(
                domain: "CloudFunctionsService",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Account ID cannot be empty"
                ]
            )
        }

        // Prepare function execution parameters
        let body = ["accountId": accountId]

        do {
            // Convert parameters to JSON string
            if let jsonBody = try? JSONSerialization.data(
                withJSONObject: body,
                options: .prettyPrinted
            ) {
                if let stringBody = String(data: jsonBody, encoding: .utf8) {
                    // Execute the Appwrite function
                    let response =
                        try await functions
                        .createExecution(
                            functionId: "delete-account",
                            body: stringBody,
                            async: true
                        )
                    print("response: \(response.toMap())")
                    // Return success based on function execution status
                    return response.status == "200"
                }
            }

            // If JSON conversion fails, throw an error
            throw NSError(
                domain: "CloudFunctionsService",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to prepare function parameters"
                ]
            )
        } catch {
            // Wrap any errors in our service's error domain
            throw NSError(
                domain: "CloudFunctionsService",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to delete account: \(error.localizedDescription)"
                ]
            )
        }
    }
}
