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
    private var subscription: RealtimeSubscription?
    
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
        //let currentDateTime = Date()
        //print("Current Date: \(currentDateTime)")

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formattedDateTime = formatter.string(from: Date())
        print("Formatted ISO8601 Date: \(formattedDateTime)")
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
    
    
    @MainActor
    func getConversationDetails(_ accountId: String) async -> [ConversationDetailModel]{
        print("Getting conversations for user: \(accountId)")
        var conversationDetails: [ConversationDetailModel] = []
        
        do {
            let conversationIds = await getConversations(accountId)
            print("Fetched conversation IDs: \(conversationIds)")
            
            for conversationId in conversationIds {
                do {
                    let participants = try await messagingService.getParticipants(for: conversationId)
                    
                    guard let otherParticipantId = participants.first(where: {$0 != accountId}) else{
                        continue
                    }
                    
                    let messagerName = await getParticipantName(otherParticipantId)
                    print("The messager is \(messagerName)")
                    let messages = try await messagingService.getMessages(conversationId, 100)
                    
                    if let lastMessage = messages.max(by: {$0.data.createdAt < $1.data.createdAt}){  //gets last sent message
                        print("The last message is \(lastMessage)")
                        let timestamp = formatTimestamp(lastMessage.data.createdAt)
                        print("The timestamp is \(timestamp)")
                        
                        let conversationDetail = ConversationDetailModel(
                            id: conversationId,
                            messagerName: messagerName,
                            lastMessage: lastMessage.data.message,
                            timestamp: timestamp
                        )
                        conversationDetails.append(conversationDetail)
                    }
                } catch {
                    print("failed to process conversation \(conversationId): \(error)")
                }
            }
        } 
        
        return conversationDetails
    }
    
    
    private func getParticipantName(_ participantId: String) async -> String {
        do {
            if let user = try await userManagementService.getUser(participantId) {
                return user.data.name
            }
        } catch {
            print("Failed to get participant name for ID \(participantId): \(error)")
        }
        return "Unknown"
    }
    
    func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeZone = TimeZone.current
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return "Unknown"
    }
    
    func subscribeToMessages(conversationId: String, onNewMessage: @escaping (MessageDocument) -> Void) async {
        do{
            try await messagingService.subscribeToMessages(
                conversationId: conversationId,
                onNewMessage: {newMessage in
                    DispatchQueue.main.async{
                        onNewMessage(newMessage)
                    }
                }
            )
            print("MessagingViewModel - Subscribed to real-time messages for conversation: \(conversationId)")
            
            
        }catch{
            print("MessagingViewModel - Failed to subscribe to real-time messages: \(error.localizedDescription)")
        }
        
    }
    
    func unsubscribeFromMessages() async {
        await messagingService.unsubscribeFromMesages()
    }
    
    
}
