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
    func createConversation(_ participants: [String]) async {
        do{
            let newConversation = ConversationModel(participants: participants)
            let conversation = try await messagingService.createConversation(newConversation)
            for accountId in participants{
                if let userModel  = try await userManagementService.getUser(accountId) {
                    if let conversations = userModel.data.conversations{
                        var newConversations = conversations
                        print("old: \(newConversations)")
                        newConversations.append(conversation.id)
                        print("new: \(newConversations)")
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
}
