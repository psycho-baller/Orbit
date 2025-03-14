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

class UserViewModel: NSObject, ObservableObject, PreciseLocationManagerDelegate,
    CampusLocationDelegate
{

    @Published var users: [UserModel] = []
    @Published var cachedUsernames: Set<String> = []  // Store usernames locally
    @Published var currentUser: UserModel?  // The current logged-in user
    @Published var error: String?
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var currentArea: String?  // Updated area name for the user
    @Published var selectedInterests: [String] = []
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var selectedRadius: Double = 10.0
    @Published var isOnCampus = false  // Track if the user is inside campus
    @Published var allUsers: [UserModel] = []

    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()
    private var appwriteRealtimeClient = AppwriteService.shared.realtime
    private var preciseLocationManager: PreciseLocationManager?
    private var campusLocationManager: CampusLocationManager
    private let areaData: [Area]  // Load JSON area data
    var lastFetchedAreaId: String?
    var lastFetchedTimestamp: Date?
    private var subscribeToLocationUpdates: RealtimeSubscription?

    init(
        campusLocationManager: CampusLocationManager = CampusLocationManager()
    ) {
        self.campusLocationManager = campusLocationManager
        self.areaData = DataLoader.loadUofCLocationDataFromJSON()
        super.init()
        campusLocationManager.delegate = self
        campusLocationManager.checkIfInsideCampus()
    }

    @MainActor
    func initialize() async {
        self.error = nil
        print(
            "UserViewModel - initialize: Initializing user list and subscribing to real-time updates."
        )
        //        self.preciseLocationManager = PreciseLocationManager()
        //        preciseLocationManager?.delegate = self  // Set delegate to receive location updates
        //        await subscribeToRealtimeUpdates()
        //                self.allUsers = await getAllUsers()
        // await fetchAllUsernames()
    }

    @MainActor
    func fetchCurrentUser() async {

        do {
            if let user = try await userManagementService.getCurrentUser() {
                self.currentUser = user

                print(
                    "UserViewModel - fetchCurrentUser: Successfully fetched current user \(user.hasCompletedOnboarding)."
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
        personalPreferences: PersonalPreferences? = nil,
        interactionPreferences: InteractionPreferencesModel? = nil,
        friendshipValues: FriendshipValuesModel? = nil,
        bio: String? = nil,
        dob: Date? = nil,
        showStarSign: Bool? = nil,
        intentions: [UserIntention]? = [],
        userLanguages: [UserLanguageModel]? = [],
        userLinks: [UserLinkModel]? = [],
        gender: UserGender? = nil,
        pronouns: [UserPronouns] = [],
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
        currentUser.personalPreferences =
            personalPreferences ?? currentUser.personalPreferences
        currentUser.interactionPreferences =
            interactionPreferences ?? currentUser.interactionPreferences
        currentUser.friendshipValues =
            friendshipValues ?? currentUser.friendshipValues
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
        if let userFromDatabase = users.first(where: {
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
            self.users = allUsers.map(\.data)
            DispatchQueue.main.async {
                self.cachedUsernames = Set(
                    self.users.map { $0.username.lowercased() })
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

    @MainActor
    func updateSurroundingUsers(areaId: String) async {
        // Initialize lastFetchedTimestamp if it's nil
        let currentTime = Date()
        if lastFetchedTimestamp == nil {
            self.lastFetchedTimestamp = currentTime
        }

        guard let lastFetchedTimestamp = self.lastFetchedTimestamp else {
            // This guard should only ever fail if something goes wrong after initialization.
            return
        }
        let timeDifference = currentTime.timeIntervalSince(lastFetchedTimestamp)

        guard areaId != lastFetchedAreaId || timeDifference > 60 else {
            // If the area hasn't changed and it's been less than a minute, skip the fetch
            print(
                "Area hasn't changed or hasn't been a minute since last fetch.")
            return
        }

        // Proceed with the fetch as area has changed or it's been more than a minute
        self.lastFetchedAreaId = areaId
        self.lastFetchedTimestamp = currentTime
        print(
            "UserViewModel - fetchUsersInArea: Fetching users in area \(areaId)"
        )

        let surroundingAreas = getSurroundingAreas(areaId: areaId)
        do {
            let userDocuments =
                try await userManagementService.listUsersInAreas(
                    surroundingAreas.map(\.id))
            self.users = userDocuments.map(\.data)
            print(
                "UserViewModel - fetchUsersInArea: Successfully fetched \(self.users.count) users."
            )
        } catch {
            print(
                "UserViewModel - fetchUsersInArea: Error fetching users in area: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    func getSurroundingAreas(areaId: String, _ radius: Int = 75) -> [Area] {
        // Get the coordinates of the current area
        let myArea = areaData.first(where: { $0.id == areaId })

        guard let myLatitude = self.currentLocation?.latitude ?? myArea?.lat,
            let myLongitude = self.currentLocation?.longitude ?? myArea?.lon
        else {
            return []
        }

        let myLocation = CLLocation(
            latitude: myLatitude,
            longitude: myLongitude
        )

        // Filter areas within the radius
        let surroundingAreas = areaData.filter { area in
            let areaLocation = CLLocation(
                latitude: area.lat, longitude: area.lon)
            // Calculate the distance between the current area and each area
            let distance = myLocation.distance(
                from: areaLocation)
            return distance <= Double(radius)
        }

        print(
            "UserViewModel - getSurroundingAreas: Found \(surroundingAreas.count) areas."
        )
        print(surroundingAreas.map(\.name))
        return surroundingAreas
    }

    // Aggregate unique interests from all users
    var allInterests: [String] {
        let activitiesArray = users.compactMap {
            $0.personalPreferences?.activitiesHobbies
        }.flatMap { $0 }
        return Array(Set(activitiesArray)).sorted()
    }

    // Filter users based on selected interests and search text
    var filteredUsers: [UserModel] {
        let lowercasedSearchText = searchText.lowercased()
        let selectedInterestsSet = Set(selectedInterests)

        return users.filter { user in
            guard user.accountId != currentUser?.accountId else { return false }

            #warning("TODO: do we rlly need search for user's usernames")
            let matchesSearchText =
                lowercasedSearchText.isEmpty
                || user.username.lowercased().contains(lowercasedSearchText)
                || (user.personalPreferences?.activitiesHobbies?.joined(
                    separator: " "
                ).lowercased()
                    .contains(lowercasedSearchText) ?? false)

            let matchesInterests =
                selectedInterests.isEmpty
                || (user.personalPreferences?.activitiesHobbies != nil
                    && !Set(user.personalPreferences!.activitiesHobbies!)
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

    // MARK - Location Updates

    // MARK: - CampusLocationDelegate Methods
    func didEnterCampus() {
        isOnCampus = true
        print("User entered campus. Starting precise location tracking.")
    }

    func didExitCampus() {
        isOnCampus = false
        print("User exited campus. Stopping precise location tracking.")
        preciseLocationManager?.stopTrackingLocation()  // Stop tracking when off-campus
        currentArea = nil  // Clear current area when outside campus
        Task {
            do {
                try await subscribeToLocationUpdates?.close()
            } catch {
                print(
                    "UserViewModel - didExitCampus: Error unsubscribing to location updates: \(error.localizedDescription)"
                )
            }
        }

    }

    // MARK: - PreciseLocationDelegate Methods
    func didUpdateLocation(latitude: Double, longitude: Double) {
        print(
            "UserViewModel - didUpdateLocation: Received location update - Latitude: \(latitude), Longitude: \(longitude)."
        )
        self.currentLocation = CLLocationCoordinate2D(
            latitude: latitude, longitude: longitude)
        // Calculate nearest area based on location
        if let nearestArea = findNearestArea(
            latitude: latitude, longitude: longitude)
        {
            self.currentArea = nearestArea.name
            Task {
                await updateUserGeneralLocation(areaId: nearestArea.id)
                if !isPreviewMode {
                    await updateSurroundingUsers(areaId: nearestArea.id)
                }
            }
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
    // MARK: - Meetup Control for High-Accuracy Mode

    func initiateMeetup() {
        guard isOnCampus else {
            print("User is outside campus; high accuracy is not enabled.")
            return
        }
        preciseLocationManager?
            .enableHighAccuracyForMeetup()  // Enable high accuracy for meetup
        print("UserViewModel: High-accuracy tracking enabled for meetup.")
    }

    func endMeetup() {
        preciseLocationManager?
            .disableHighAccuracyAfterMeetup()  // Return to standard accuracy after meetup
        print("UserViewModel: High-accuracy tracking disabled after meetup.")
    }

    @MainActor
    func updateUserGeneralLocation(areaId: String) async {
        // assert that the area is new and the user is within campus
        guard currentUser?.currentAreaId != areaId else {
            print(
                "UserViewModel - updateUserGeneralLocation: User is already in area \(areaId)."
            )
            return
        }
        guard isOnCampus else {
            print(
                "UserViewModel - updateUserGeneralLocation: User is outside campus."
            )
            return
        }
        do {
            print("Updating general location for user to area ID \(areaId).")
            guard
                let currentUser =
                    try await userManagementService.getCurrentUser()
            else {
                print("Current user not found.")
                return
            }
            var updatedUser = currentUser
            updatedUser.currentAreaId = areaId

            await updateUser(id: currentUser.id, updatedUser: updatedUser)
            self.currentUser = updatedUser
            print("Successfully updated general location for user.")
        } catch {
            print(
                "Error updating general location: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func subscribeToRealtimeUpdates() async {
        print(
            "UserViewModel - subscribeToRealtimeUpdates: Subscribing to real-time updates."
        )
        do {
            subscribeToLocationUpdates =
                try await appwriteRealtimeClient
                .subscribe(
                    channels: [
                        "databases.\(AppwriteService.shared.databaseId).collections.users.documents"
                    ]
                ) { event in
                    if let payload = event.payload {
                        Task {
                            let updatedUser = try JSONDecoder().decode(
                                UserModel.self,
                                from: JSONSerialization.data(
                                    withJSONObject: payload))
                            self.handleRealtimeUserUpdate(updatedUser)
                            print(
                                "UserViewModel - subscribeToRealtimeUpdates: Received real-time update for user \(updatedUser.accountId)."
                            )
                        }
                    }
                }
            print(
                "UserViewModel - subscribeToRealtimeUpdates: Successfully subscribed to real-time updates."
            )
        } catch {
            print(
                "UserViewModel - Source: subscribeToRealtimeUpdates - Error: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func handleRealtimeUserUpdate(_ updatedUser: UserModel) {
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
            if updatedUser.accountId == currentUser?.accountId {
                self.currentUser = updatedUser  // Update currentUser if it's the one being updated in real-time
            }
            print(
                "UserViewModel - handleRealtimeUserUpdate: Updated user \(updatedUser.accountId) in local list."
            )
        } else {
            users.append(updatedUser)
            print(
                "UserViewModel - handleRealtimeUserUpdate: Added new user \(updatedUser.accountId) to local list."
            )
        }
    }

    // Helper function to filter users by location proximity
    func usersNearby(users: [UserModel], radius: Double) -> [UserModel] {
        guard let currentAreaId = currentUser?.currentAreaId else {
            print(
                "UserViewModel - usersInSameArea: Current area not available.")
            return []
        }

        print(
            "UserViewModel - usersInSameArea: Filtering users in area \(currentAreaId)."
        )

        return users.filter { user in
            guard let userAreaId = user.currentAreaId else {
                print(
                    "UserViewModel - usersInSameArea: Skipping user \(user.id), missing area data."
                )
                return false
            }
            let isInSameArea = userAreaId == currentAreaId
            if isInSameArea {
                print(
                    "UserViewModel - usersInSameArea: User \(user.id) is in the same area."
                )
            }
            return isInSameArea
        }
    }

    @MainActor
    func updateUserInterests(interests: [String]) async {
        guard var user = currentUser else { return }

        user.interests = interests
        self.currentUser?.interests = interests
        print(
            "UserViewModel - updateUserInterests: Updating interests to \(interests)."
        )

        do {
            // Await the updateUser function which expects accountId and updatedUser
            let updatedUserDocument =
                try await userManagementService.updateUser(
                    accountId: user.accountId, updatedUser: user)

            if let updatedUserDocument = updatedUserDocument {
                print(
                    "Profile updated successfully for user \(updatedUserDocument.id)"
                )
            } else {
                print("Failed to update user: User document not found.")
            }
        } catch {
            print("Error updating profile: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }

    func getAreaName(forId id: Int) -> String {
        if let area = areaData.first(where: { String($0.id) == String(id) }) {
            return area.name
        }
        return "Unknown Location"
    }
}

// MARK: - Mock for SwiftUI Preview
#if DEBUG
    extension UserViewModel {
        static func mock() -> UserViewModel {
            let mockVM = UserViewModel()

            // Set current user
            mockVM.currentUser = .mock()

            // Set other users
            mockVM.users = UserModel.mockUsers()

            return mockVM
        }
    }
#endif
