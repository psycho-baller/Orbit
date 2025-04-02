//
//  UserViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-07.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

@preconcurrency import Appwrite
import CoreLocation
import Foundation
import JSONCodable
import SwiftUI
import Loaf

// struct OnboardingUpdate {
//     var personalPreferences: PersonalPreferences?
//     var interactionPreferences: InteractionPreferencesModel?
//     var friendshipValues: FriendshipValuesModel?
//     var bio: String?
//     var dob: Date?
//     var markComplete: Bool = false
// }

// enum OnboardingError: Error {
//     case noCurrentUser
// }

class UserViewModel: NSObject, ObservableObject {

    @Published var cachedUsernames: Set<String> = []  // Store usernames locally
    @Published var currentUser: UserModel?  // The current logged-in user
    @Published var error: String?
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var currentArea: String?  // Updated area name for the user
    @Published var selectedInterests: [String] = []
    @Published var allUsers: [UserModel] = []

    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()
    private var appwriteRealtimeClient = AppwriteService.shared.realtime
    private let areaData: [Area]  // Load JSON area data

    override init() {
        self.areaData = DataLoader.loadUofCLocationDataFromJSON()
        super.init()
        Task { await initialize() }
    }

    @MainActor
    func initialize() async {
        self.error = nil
        print(
            "UserViewModel - initialize: Initializing user list and subscribing to real-time updates."
        )
        if !isPreviewMode {
            await self.fetchCurrentUser()
            await self.prefillUsefulUserData()
        }
    }

    @MainActor
    func fetchCurrentUser() async {

        do {
            if let user = try await userManagementService.getCurrentUser() {
                self.currentUser = user

                print(
                    "UserViewModel - fetchCurrentUser: Successfully fetched current user \(String(describing: user.accountId))."
                )
            } else {
                print(
                    "UserViewModel - fetchCurrentUser: No current user found."
                )
            }
        } catch {
            print(
                "UserViewModel - Source: fetchCurrentUser - Error: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func getUserDocument(accountId: String) async -> UserDocument? {
        do {
            let userDocument = try await userManagementService.getUser(
                accountId)
            return userDocument
        } catch {
            print(
                "UserViewModel - Source: getUserDocument - Error: \(error.localizedDescription)"
            )
        }
        return nil
    }

    /// Get all users in the DB
    func getAllUsers() async -> [UserModel] {
        do {
            let allUsers = try await userManagementService.listUsers(queries: [
                //                Query.equal("isInterestedToMeet", value: true)
            ])
            return allUsers.map(\.data)

        } catch {
            print(
                "UserViewModel - Source: getAllUsers - Error: \(error.localizedDescription)"
            )
        }
        return []
    }

    @MainActor
    func saveOnboardingData(
        activitiesHobbies: [String]? = nil,
        friendActivities: [String]? = nil,
        preferredMeetupType: [String]? = nil,
        convoTopics: [String]? = nil,
        //        preferredMinAge: Int? = nil,
        //        preferredMaxAge: Int? = nil,
        //        preferredGender: [UserGender]? = nil,
        friendshipValues: [String]? = nil,
        friendshipQualities: [String]? = nil,
        bio: String? = nil,
        dob: Date? = nil,
        showStarSign: Bool? = nil,
        intentions: [UserIntention]? = nil,
        userLanguages: [UserLanguageModel]? = nil,
        userLinks: [UserLinkModel]? = nil,
        gender: UserGender? = nil,
        pronouns: [UserPronouns]? = nil,
        markComplete: Bool = false
    ) async {
        guard var currentUser = currentUser else {
            print("Error: No current user found.")
            return
        }

        //        // Update only the non-nil properties
        //        if let personalPreferences = personalPreferences {
        //            currentUser.personalPreferences = personalPreferences
        //        }
        //        if let socialStyle = socialStyle {
        //            currentUser.socialStyle = socialStyle
        //        }
        //        if let interactionPreferences = interactionPreferences {
        //            currentUser.interactionPreferences = interactionPreferences
        //        }
        //        if let friendshipValues = friendshipValues {
        //            currentUser.friendshipValues = friendshipValues
        //        }
        //        if let socialSituations = socialSituations {
        //            currentUser.socialSituations = socialSituations
        //        }

        // Update the user's onboarding data locally
        currentUser.activitiesHobbies =
            activitiesHobbies ?? currentUser.activitiesHobbies
        currentUser.friendActivities =
            friendActivities ?? currentUser.friendActivities
        currentUser.preferredMeetupType =
            preferredMeetupType ?? currentUser.preferredMeetupType
        currentUser.convoTopics = convoTopics ?? currentUser.convoTopics
        //        currentUser.preferredMinAge =
        //            preferredMinAge ?? currentUser.preferredMinAge
        //        currentUser.preferredMaxAge =
        //            preferredMaxAge ?? currentUser.preferredMaxAge
        //        currentUser.preferredGender =
        //            preferredGender ?? currentUser.preferredGender
        currentUser.friendshipValues =
            friendshipValues ?? currentUser.friendshipValues
        currentUser.friendshipQualities =
            friendshipQualities ?? currentUser.friendshipQualities
        currentUser.bio = bio ?? currentUser.bio
        currentUser.intentions = intentions ?? currentUser.intentions
        currentUser.userLanguages = userLanguages ?? currentUser.userLanguages
        currentUser.gender = gender ?? currentUser.gender
        currentUser.pronouns = pronouns ?? currentUser.pronouns
        currentUser.userLinks = userLinks ?? currentUser.userLinks
        if let dateOfBirth = dob {
            currentUser.dob = DateFormatterUtility.formatDateOnly(dateOfBirth)
        }
        currentUser.showStarSign = showStarSign ?? currentUser.showStarSign
        if markComplete {
            currentUser.hasCompletedOnboarding = true
        }

        await updateUser(
            id: currentUser.accountId, updatedUser: currentUser)
    }

    //Get the User's name from their ID. (Used for chat requests)
    func getUserName(from id: String) -> String {
        //        space inefficient
        if let userFromLocal = allUsers.first(where: { $0.accountId == id }) {
            return userFromLocal.firstName + " "
                + (userFromLocal.lastName ?? "")
        }
        return "Unknown"
    }

    // setCurrentUser
    @MainActor
    func updateCurrentUser(accountId: String) async -> Bool {
        #warning(
            "This function only updates CURRENTUSER variable, not the backend DB."
        )
        if let userFromDatabase = allUsers.first(where: {
            $0.accountId == accountId
        }) {
            self.currentUser = userFromDatabase
            return true
        }
        return false
    }

    @MainActor
    func createUser(userData: UserModel) async -> UserDocument? {
        do {
            print(
                "UserViewModel - createUser: Attempting to create user with ID \(userData.accountId)."
            )
            let newUser = try await userManagementService.createUser(userData)
            print(
                "UserViewModel - createUser: User \(newUser.id) successfully created."
            )
            // await listUsers()  // Refresh the user list after creation
            self.currentUser = userData  // Set the currentUser to the newly created user
            return newUser
        } catch {
            print(
                "UserViewModel - Source: createUser - Error while creating user with ID \(userData.accountId): \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
        return nil
    }

    @MainActor
    func updateUser(id: String, updatedUser: UserModel) async {
        do {
            print(
                "UserViewModel - updateUser: Attempting to update user with ID \(id)."
            )
            guard
                let updatedUserDocument =
                    try await userManagementService.updateUser(
                        accountId: id, updatedUser: updatedUser)
            else {
                throw NSError(
                    domain: "User not found", code: 404, userInfo: nil)
            }
            print(
                "UserViewModel - updateUser: User \(updatedUserDocument.id) successfully updated."
            )
            if id == currentUser?.accountId {
                self.currentUser = updatedUser  // Update the currentUser if it's the one being updated
            }
            //            await listUsers()  // Refresh the user list after update
        } catch {
            print(
                "UserViewModel - Source: updateUser - Error while updating user with ID \(id): \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func deleteUser(id: String) async {
        do {
            print(
                "UserViewModel - deleteUser: Attempting to delete user with ID \(id)."
            )
            try await userManagementService.deleteUser(id)
            print(
                "UserViewModel - deleteUser: User \(id) successfully deleted.")
            if id == currentUser?.accountId {
                self.currentUser = nil  // Clear the currentUser if it's the one being deleted
            }
        } catch {
            print(
                "UserViewModel - Source: deleteUser - Error while deleting user with ID \(id): \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    @MainActor
    /// Load all usernames once when the app starts or when needed
    func prefillUsefulUserData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allUsers = try await userManagementService.listUsers(
                queries: nil)
            self.allUsers = allUsers.map(\.data)
            DispatchQueue.main.async {
                self.cachedUsernames = Set(
                    self.allUsers.map { $0.username.lowercased() })
            }
        } catch {
            print("Error fetching usernames: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }

    /// Check if a username is available using the cached list
    func isUsernameAvailable(_ username: String) -> Bool {
        return !cachedUsernames.contains(username.lowercased())
    }

    @MainActor
    func toggleIsInterestedToMeet() async {
        guard let currentUser = currentUser else {
            print("No current user available to toggle isInterestedToMeet.")
            return
        }

        // add something that you need to toggle for the user

        do {
            // Update the user in the Appwrite database
            print(
                "Toggling isInterestedToMeet for user \(currentUser.accountId)."
            )
            guard
                let updatedUserDocument =
                    try await userManagementService.updateUser(
                        accountId: currentUser.accountId,
                        updatedUser: currentUser)
            else {
                throw NSError(
                    domain: "User not found", code: 404, userInfo: nil)
            }

            // Update the `currentUser` property with the latest data
            self.currentUser = currentUser

            print(
                "Successfully toggled isInterestedToMeet for user \(updatedUserDocument.id)."
            )
        } catch {
            print(
                "Error toggling isInterestedToMeet: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    // Aggregate unique interests from all users
    var allInterests: [String] {
        let activitiesArray = allUsers.compactMap {
            $0.activitiesHobbies
        }.flatMap { $0 }
        return Array(Set(activitiesArray)).sorted()
    }

    // Filter users based on selected interests and search text
    var filteredUsers: [UserModel] {
        let lowercasedSearchText = searchText.lowercased()
        let selectedInterestsSet = Set(selectedInterests)

        return allUsers.filter { user in
            guard user.accountId != currentUser?.accountId else { return false }

            #warning("TODO: do we rlly need search for user's usernames")
            let matchesSearchText =
                lowercasedSearchText.isEmpty
                || user.username.lowercased().contains(lowercasedSearchText)
                || (user.activitiesHobbies?.joined(
                    separator: " "
                ).lowercased()
                    .contains(lowercasedSearchText) ?? false)

            let matchesInterests =
                selectedInterests.isEmpty
                || (user.activitiesHobbies != nil
                    && !Set(user.activitiesHobbies!)
                        .intersection(selectedInterestsSet)
                        .isEmpty)

            return matchesSearchText && matchesInterests
        }
    }

    func toggleInterest(_ interest: String) {
        print("UserViewModel - toggleInterest: Toggling interest: \(interest).")
        if let index = selectedInterests.firstIndex(of: interest) {
            selectedInterests.remove(at: index)
        } else {
            selectedInterests.append(interest)
        }
    }

    // Helper to find the nearest area from a given latitude and longitude
    func findNearestArea(latitude: Double, longitude: Double) -> Area? {
        guard !areaData.isEmpty else {
            print("No area data available.")
            return nil
        }

        // User's current location
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)

        // Find the area with the minimum distance from the user
        var nearestArea: Area?
        var minimumDistance: CLLocationDistance = .greatestFiniteMagnitude

        for area in areaData {
            // Area location
            let areaLocation = CLLocation(
                latitude: area.lat, longitude: area.lon)
            // Calculate distance between user's location and area location
            let distance = userLocation.distance(from: areaLocation)

            // Check if this area is closer than previously found areas
            if distance < minimumDistance {
                minimumDistance = distance
                nearestArea = area
            }
        }

        // Log result for debugging
        if let nearestArea = nearestArea {
            print(
                "Nearest area: \(nearestArea.name) at distance: \(minimumDistance) meters."
            )
        }

        return nearestArea
    }

    @MainActor
    func handleRealtimeUserUpdate(_ updatedUser: UserModel) {
        if let index = allUsers.firstIndex(where: { $0.id == updatedUser.id }) {
            allUsers[index] = updatedUser
            if updatedUser.accountId == currentUser?.accountId {
                self.currentUser = updatedUser  // Update currentUser if it's the one being updated in real-time
            }
            print(
                "UserViewModel - handleRealtimeUserUpdate: Updated user \(updatedUser.accountId) in local list."
            )
        } else {
            allUsers.append(updatedUser)
            print(
                "UserViewModel - handleRealtimeUserUpdate: Added new user \(updatedUser.accountId) to local list."
            )
        }
    }

    func getAreaName(forId id: Int) -> String {
        if let area = areaData.first(where: { String($0.id) == String(id) }) {
            return area.name
        }
        return "Unknown Location"
    }

    @MainActor
    func updateAndSaveUserData(
        username: String? = nil,
        firstName: String? = nil,
        lastName: Optional<String>? = nil,
        bio: Optional<String>? = nil,
        dob: String? = nil,
        activitiesHobbies: [String]? = nil,
        friendActivities: [String]? = nil,
        preferredMeetupType: [String]? = nil,
        convoTopics: [String]? = nil,
        friendshipValues: [String]? = nil,
        friendshipQualities: [String]? = nil,
        pronouns: [UserPronouns]? = nil,
        intentions: [UserIntention]? = nil,
        featuredInterests: [String]? = nil,
        gender: UserGender? = nil,
        showPronouns: Bool? = nil,
        showGender: Bool? = nil,
        sectionName: String? = nil
    ) async {
        guard var updatedUser = currentUser else { return }
        
        // Update only the fields that were provided
        if let username = username {
            updatedUser.username = username
        }
        if let firstName = firstName {
            updatedUser.firstName = firstName
        }
        
        // Handle optional fields differently 
        if let lastNameOptional = lastName {
            updatedUser.lastName = lastNameOptional
        }
        if let bioOptional = bio {
            updatedUser.bio = bioOptional
        }
        
        if let dob = dob {
            updatedUser.dob = dob
        }
        if let activitiesHobbies = activitiesHobbies {
            updatedUser.activitiesHobbies = activitiesHobbies
        }
        if let friendActivities = friendActivities {
            updatedUser.friendActivities = friendActivities
        }
        if let preferredMeetupType = preferredMeetupType {
            updatedUser.preferredMeetupType = preferredMeetupType
        }
        if let convoTopics = convoTopics {
            updatedUser.convoTopics = convoTopics
        }
        if let friendshipValues = friendshipValues {
            updatedUser.friendshipValues = friendshipValues
        }
        if let friendshipQualities = friendshipQualities {
            updatedUser.friendshipQualities = friendshipQualities
        }
        if let pronouns = pronouns {
            updatedUser.pronouns = pronouns
        }
        if let intentions = intentions {
            updatedUser.intentions = intentions
        }
        if let featuredInterests = featuredInterests {
            updatedUser.featuredInterests = featuredInterests
        }
        if let gender = gender {
            updatedUser.gender = gender
        }
        if let showPronouns = showPronouns {
            updatedUser.showPronouns = showPronouns
        }
        if let showGender = showGender {
            updatedUser.showGender = showGender
        }
        
        isLoading = true
        
        // Create a temporary copy
        let tempUser = currentUser
        
        // Force UI update by setting to nil and back
        self.currentUser = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.currentUser = updatedUser
            self.objectWillChange.send()
        }
        
        do {
            // Save to database
            try await updateUserWithError(id: updatedUser.accountId, updatedUser: updatedUser)
            
            // Only show success toast after successful update
            if let section = sectionName {
                showSuccessToast(section)
            }
        } catch {
            // Revert to original user if update fails
            self.currentUser = tempUser
            self.objectWillChange.send()
            
            // Show error toast with the section name if provided
            if let section = sectionName {
                showErrorToast("Failed to update \(section.lowercased())")
            } else {
                showErrorToast("Update failed")
            }
            
            // Set the error property for other UI components to use
            self.error = error.localizedDescription
            print("UserViewModel - updateAndSaveUserData: Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }

    // Modified updateUser function that throws errors instead of handling them internally
    @MainActor
    private func updateUserWithError(id: String, updatedUser: UserModel) async throws {
        print("UserViewModel - updateUser: Attempting to update user with ID \(id).")
        
        guard let updatedUserDocument = try await userManagementService.updateUser(
            accountId: id, updatedUser: updatedUser)
        else {
            throw NSError(domain: "User not found", code: 404, userInfo: nil)
        }
        
        print("UserViewModel - updateUser: User \(updatedUserDocument.id) successfully updated.")
    }

    // Function to show success toast
    private func showSuccessToast(_ section: String) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first {
                
                // Get the key window from the active scene
                if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
                   let rootViewController = keyWindow.rootViewController {
                    
                    // Show toast on the root view controller
                    Loaf("\(section) updated successfully", state: .success, location: .top, sender: rootViewController).show()
                }
            }
        }
    }

    // Function to show error toast
    private func showErrorToast(_ message: String) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first {
                
                // Get the key window from the active scene
                if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
                   let rootViewController = keyWindow.rootViewController {
                    
                    // Show toast on the root view controller
                    Loaf(message, state: .error, location: .top, sender: rootViewController).show()
                }
            }
        }
    }
}

// MARK: - Mock for SwiftUI Preview
#if DEBUG
    extension UserViewModel {
        static func mock() -> UserViewModel {
            let mockVM = UserViewModel()

            // Set current user
            mockVM.currentUser = .mock2()

            // Set other users
            mockVM.allUsers = UserModel.mockUsers()

            return mockVM
        }
    }
#endif
