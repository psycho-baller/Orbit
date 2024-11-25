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

class UserViewModel: NSObject, ObservableObject, PreciseLocationManagerDelegate,
    CampusLocationDelegate
{

    @Published var users: [UserModel] = []
    @Published var currentUser: UserModel?  // The current logged-in user
    @Published var error: String?
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var currentArea: String?  // Updated area name for the user
    @Published var selectedInterests: [String] = []
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var selectedRadius: Double = 10.0
    @Published var isOnCampus = false  // Track if the user is inside campus

    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()
    private var appwriteRealtimeClient = AppwriteService.shared.realtime
    private var preciseLocationManager: PreciseLocationManager?
    private var campusLocationManager: CampusLocationManager
    private let areaData: [Area]  // Load JSON area data
    private var lastFetchedAreaId: String?  // Track last fetched area
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
        self.preciseLocationManager = PreciseLocationManager()
        preciseLocationManager?.delegate = self  // Set delegate to receive location updates
        await fetchCurrentUser()
        await subscribeToRealtimeUpdates()
    }

    @MainActor
    private func fetchCurrentUser() async {

        do {
            if let user = try await userManagementService.getCurrentUser() {
                self.currentUser = user
                print(
                    "UserViewModel - fetchCurrentUser: Successfully fetched current user \(user.accountId)."
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

    //Get the User's name from their ID. (Used for chat requests)
    func getUserName(from id: String) -> String {
        if let user = users.first(where: { $0.accountId == id }) {
            return user.name
        }
        return "Unknown"
    }

    // setCurrentUser
    @MainActor
    func updateCurrentUser(accountId: String) async {
        let userFromDatabase = users.first { $0.accountId == accountId }
        self.currentUser = userFromDatabase
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
    func toggleIsInterestedToMeet() async {
        guard var currentUser = currentUser else {
            print("No current user available to toggle isInterestedToMeet.")
            return
        }

        // Toggle the `isInterestedToMeet` attribute
        currentUser.isInterestedToMeet =
            !(currentUser.isInterestedToMeet ?? false)

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
    func fetchUsersInArea(areaId: String) async {
        guard areaId != lastFetchedAreaId else { return }  // Fetch only if area changed
        lastFetchedAreaId = areaId  // Update last fetched area

        print(
            "UserViewModel - fetchUsersInArea: Fetching users in area \(areaId)"
        )

        //        isLoading = true
        do {
            let userDocuments = try await userManagementService.listUsersInArea(
                areaId)
            self.users = userDocuments.map { $0.data }
            print(
                "UserViewModel - fetchUsersInArea: Successfully fetched \(self.users.count) users."
            )
        } catch {
            print(
                "UserViewModel - fetchUsersInArea: Error fetching users in area: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
        //        isLoading = false
    }

    // Aggregate unique interests from all users
    var allInterests: [String] {
        let interestsArray = users.compactMap { $0.interests }.flatMap { $0 }
        return Array(Set(interestsArray)).sorted()
    }

    // Filter users based on selected interests and search text
    var filteredUsers: [UserModel] {
        let lowercasedSearchText = searchText.lowercased()
        let selectedInterestsSet = Set(selectedInterests)

        return users.filter { user in
            //            guard user.accountId != currentUser?.accountId else { return false }
            guard user.isInterestedToMeet ?? false else { return false }

            let matchesSearchText =
                lowercasedSearchText.isEmpty
                || user.name.lowercased().contains(lowercasedSearchText)
                || (user.interests?.joined(separator: " ").lowercased()
                    .contains(
                        lowercasedSearchText) ?? false)

            let matchesInterests =
                selectedInterests.isEmpty
                || (user.interests != nil
                    && !Set(user.interests!).intersection(selectedInterestsSet)
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
                    await fetchUsersInArea(areaId: nearestArea.id)
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
}

// MARK: - Mock for SwiftUI Preview
#if DEBUG
    extension UserViewModel {
        static func mock() -> UserViewModel {
            let viewModel = UserViewModel()
            viewModel.currentUser = UserModel(
                accountId: "6707fc9594f9bf8a1f1f",
                name: "John Doe",
                interests: ["Basketball", "Music"],
                latitude: 51.078621,
                longitude: 114.136719,
                isInterestedToMeet: true,
                currentAreaId: "990215865"
            )

            // Add mock users
            viewModel.users = []
            //                UserModel(
            //                    accountId: "6726b1ef776f5badc4fe",
            //                    name: "Jane Smith",
            //                    interests: ["Reading", "Cooking"],
            //                    latitude: 51.078621,
            //                    longitude: -114.136719,
            //                    isInterestedToMeet: true,
            //                    currentAreaId: "990215865"
            //                ),
            //                UserModel(
            //                    accountId: "11223",
            //                    name: "Michael Brown",
            //                    interests: ["Video Games", "Art"],
            //                    latitude: 51.078621,
            //                    longitude: -114.136719,
            //                    isInterestedToMeet: true,
            //                    currentAreaId: "990215865"
            //                ),
            //                UserModel(
            //                    accountId: "33445",
            //                    name: "Emily White",
            //                    interests: ["Travel", "Movies"],
            //                    latitude: 51.078621,
            //                    longitude: -114.136719,
            //                    isInterestedToMeet: true,
            //                    currentAreaId: "990215865"
            //                ),
            //                UserModel(
            //                    accountId: "55667",
            //                    name: "David Green",
            //                    interests: ["Basketball", "Music", "Art"],
            //                    latitude: 51.078621,
            //                    longitude: -114.136719,
            //                    isInterestedToMeet: true,
            //                    currentAreaId: "990215865"
            //                ),
            //                UserModel(
            //                    accountId: "77889",
            //                    name: "Sophia Black",
            //                    interests: ["Hiking", "Photography"],
            //                    latitude: 51.078621,
            //                    longitude: -114.136719,
            //                    isInterestedToMeet: true,
            //                    currentAreaId: "990215865"
            //                ),
            //            ]
            return viewModel
        }
    }
#endif
