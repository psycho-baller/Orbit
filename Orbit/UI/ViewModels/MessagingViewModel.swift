//
//  MessagingViewModel.swift
//  Orbit
//
//  Created by Jessy Tseng on 2024-11-02.
//

@preconcurrency import Appwrite
import Foundation
import Appwrite

class MessagingViewModel: ObservableObject{
    private var messagingService: MessagingServiceProtocol = MessagingService()
    private var userManagementService: UserManagementServiceProtocol = UserManagementService()
    
    @MainActor
    func getConversations(_ accountId: String) async -> [String]{
        do{
            if let userModel = try await userManagementService.getUser(accountId){
                if let conversations = userModel.data.conversations{
                    return conversations
                }
            }
            throw NSError(domain: "UsersNotFound: \"\(accountId)\"", code: 404)
        } catch {
            print("MessagingViewModel - getConversations failed \(error.localizedDescription)")
            return []
        }
    }
    
    
    @MainActor
    func createConversation(_ participants: [String]) async {
        do{
            // Create entry in conversation table
            let conversationData = ConversationModel(participants: participants)
            let conversationEntry = try await messagingService.createConversation(conversationData)
            
            // Add conversation id to users
            for accountId in participants{
                if let userModel  = try await userManagementService.getUser(accountId) {
                    if let conversations = userModel.data.conversations{
                        var newConversations = conversations
                        newConversations.append(conversationEntry.id)
                        let newUserModel = UserModel(
                            accountId: accountId,
                            name: userModel.data.name,
                            interests: userModel.data.interests,
                            latitude: userModel.data.latitude,
                            longitude: userModel.data.longitude,
                            isInterestedToMeet: userModel.data.isInterestedToMeet,
                            conversations: newConversations
                        )
                        try await userManagementService.updateUser(accountId: accountId, updatedUser: newUserModel)
                    }
                }
            }
        }
        catch {
            print("MessagingViewModel - createConversation failed \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createMessage(_ conversationId: String,_ senderAccountId: String, _ message: String) async {
        let currentDateTime = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let formattedDateTime = formatter.string(from: currentDateTime)
        let newMessage = MessageModel(
            conversationId: conversationId,
            senderAccountId: senderAccountId,
            message: message,
            createdAt: formattedDateTime
        )
        do{
            try await messagingService.createMessage(newMessage)
        } catch {
            print("MessagingViewModel - createMessage failed \(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func getMessages(_ conversationId: String, _ numOfMessages:Int = 100) async -> [MessageDocument] {
        do{
            let messages = try await messagingService.getMessages(conversationId, numOfMessages)
            return messages
        } catch {
            print("MessagingViewModel - createMessage failed \(error.localizedDescription)")
            return []
        }
    }
}
