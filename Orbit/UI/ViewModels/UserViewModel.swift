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

class UserViewModel: NSObject, ObservableObject, LocationManagerDelegate {

    @Published var users: [UserModel] = []
    @Published var currentUser: UserModel?  // The current logged-in user
    @Published var error: String?
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var selectedInterests: [String] = []
    @Published var currentLocation: CLLocationCoordinate2D?

    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()
    private var appwriteRealtimeClient = AppwriteService.shared.realtime
    private var locationManager: LocationManager

    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self  // Set delegate to receive location updates
        locationManager.locationManager.startUpdatingLocation()  // Start location updates
    }

    @MainActor
    func initialize() async {
        self.error = nil
        print(
            "UserViewModel - initialize: Initializing user list and subscribing to real-time updates."
        )
        await listUsers()
        await subscribeToRealtimeUpdates()
        await fetchCurrentUser()
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
                print("UserViewModel - fetchCurrentUser: No current user found.")
            }
        } catch {
            print("UserViewModel - Source: fetchCurrentUser - Error: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }

    // setCurrentUser
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
            await listUsers()  // Refresh the user list after update
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

    // Aggregate unique interests from all users
    var allInterests: [String] {
        let interestsArray = users.compactMap { $0.interests }.flatMap { $0 }
        return Array(Set(interestsArray)).sorted()
    }

    // Filter users based on selected interests and search text
    var filteredUsers: [UserModel] {
        // Filter users based on multiple criteria in a single pass
        let lowercasedSearchText = searchText.lowercased()
        let selectedInterestsSet = Set(selectedInterests)

        let filteredUsers = users.filter { user in
            // Exclude the current user
            guard user.accountId != currentUser?.accountId else { return false }

            // Exclude users not interested in meetups
            guard user.isInterestedToMeet ?? false else { return false }

            // Check if the user matches the search text
            let matchesSearchText =
                lowercasedSearchText.isEmpty
                || user.name.lowercased().contains(lowercasedSearchText)
                || (user.interests?.joined(separator: " ").lowercased().contains(
                    lowercasedSearchText) ?? false)

            // Check if the user matches the selected interests
            let matchesInterests =
                selectedInterests.isEmpty
                || (user.interests != nil
                    && !Set(user.interests!).intersection(selectedInterestsSet).isEmpty)

            return matchesSearchText && matchesInterests
        }
        return usersNearby(users: filteredUsers)
//        return filteredUsers
    }

    @MainActor
    func listUsers(queries: [String]? = nil) async {
        print("UserViewModel - listUsers: Fetching user list.")
        isLoading = true
        do {
            let userDocuments = try await userManagementService.listUsers(
                queries: queries)
            self.users = userDocuments.map { $0.data }
            print(
                "UserViewModel - listUsers: Successfully fetched \(self.users.count) users."
            )
        } catch {
            print(
                "UserViewModel - Source: listUsers - Error: \(error.localizedDescription)"
            )
            self.error = error.localizedDescription
        }
        isLoading = false
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
    func didUpdateLocation(latitude: Double, longitude: Double) {
        print(
            "UserViewModel - didUpdateLocation: Received location update - Latitude: \(latitude), Longitude: \(longitude)."
        )
        self.currentLocation = CLLocationCoordinate2D(
            latitude: latitude, longitude: longitude)
        Task {
            await updateCurrentUserLocation(
                latitude: latitude, longitude: longitude)
        }
    }

    @MainActor
    func updateCurrentUserLocation(latitude: Double, longitude: Double) async {
        print(
            "UserViewModel - updateCurrentUserLocation: Attempting to update current user's location - Latitude: \(latitude), Longitude: \(longitude)."
        )
        do {
            guard
                let currentUser =
                    try await userManagementService.getCurrentUser()
            else {
                print(
                    "UserViewModel - updateCurrentUserLocation: Current user not found, possibly anonymous."
                )
                return
            }
            var updatedUser = currentUser
            updatedUser.latitude = latitude
            updatedUser.longitude = longitude

            await updateUser(
                id: currentUser.accountId, updatedUser: updatedUser)
            self.currentUser = updatedUser  // Update currentUser's location
            print(
                "UserViewModel - updateCurrentUserLocation: Successfully updated location for user \(currentUser.accountId)."
            )
        } catch {
            print(
                "UserViewModel - Source: updateCurrentUserLocation - Error: \(error.localizedDescription)"
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
            let _subscription = try await appwriteRealtimeClient.subscribe(
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
    func usersNearby(users: [UserModel], radius: Double = 10000) -> [UserModel] {
        guard let currentLocation = currentLocation else {
            print(
                "UserViewModel - usersNearby: Current location not available.")
            return []
        }
        print(
            "UserViewModel - usersNearby: Filtering users within \(radius) meters of current location."
        )
        return users.filter { user in
            guard let userLat = user.latitude, let userLong = user.longitude
            else {
                print(
                    "UserViewModel - usersNearby: Skipping user \(user.id), missing location data."
                )
                return false
            }
            let userLocation = CLLocation(
                latitude: Double(userLat), longitude: Double(userLong))
            let currentCLLocation = CLLocation(
                latitude: currentLocation.latitude,
                longitude: currentLocation.longitude)
            let distanceFromEachOther = currentCLLocation.distance(
                from: userLocation)
            print(
                "UserViewModel - usersNearby: User \(user.id) is \(distanceFromEachOther) meters away."
            )
            return distanceFromEachOther <= radius
        }
    }

    @MainActor
    func updateUserInterests(interests: [String]) async {
        guard var user = currentUser else { return }

        user.interests = interests
        self.currentUser=currentUser
        print("UserViewModel - updateUserInterests: Updating interests to \(interests).")
        
        do {
            // Await the updateUser function which expects accountId and updatedUser
            let updatedUserDocument = try await userManagementService.updateUser(
                accountId: user.accountId, updatedUser: user)
            
            if let updatedUserDocument = updatedUserDocument {
                print("Profile updated successfully for user \(updatedUserDocument.id)")
            } else {
                print("Failed to update user: User document not found.")
            }
        } catch {
            print("Error updating profile: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }
    
    static func mock() -> UserViewModel {
        let viewModel = UserViewModel()
        viewModel.currentUser = UserModel(
            accountId: "12345",
            name: "John Doe",
            interests: ["Basketball", "Music"],
            latitude: nil,
            longitude: nil,
            isInterestedToMeet: true
        )
        
        // Add mock users
            viewModel.users = [
                UserModel(
                    accountId: "67890",
                    name: "Jane Smith",
                    interests: ["Reading", "Cooking"],
                    latitude: 51.0500,  // ~1.5 km away from John Doe
                    longitude: -114.0745,
                    isInterestedToMeet: true
                ),
                UserModel(
                    accountId: "11223",
                    name: "Michael Brown",
                    interests: ["Video Games", "Art"],
                    latitude: 51.0450,  // ~2 km away
                    longitude: -114.0650,
                    isInterestedToMeet: false
                ),
                UserModel(
                    accountId: "33445",
                    name: "Emily White",
                    interests: ["Travel", "Movies"],
                    latitude: 51.0530,  // ~4 km away
                    longitude: -114.0780,
                    isInterestedToMeet: true
                ),
                UserModel(
                    accountId: "55667",
                    name: "David Green",
                    interests: ["Basketball", "Music", "Art"],
                    latitude: 51.0700,  // ~10 km away
                    longitude: -114.1000,
                    isInterestedToMeet: false
                ),
                UserModel(
                    accountId: "77889",
                    name: "Sophia Black",
                    interests: ["Hiking", "Photography"],
                    latitude: 51.1150,  // ~25 km away
                    longitude: -114.1500,
                    isInterestedToMeet: true
                )
            ]
        return viewModel
    }
}
