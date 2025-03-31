//
//  MeetupRequestViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//

import Foundation
import SwiftUI

@MainActor
class MeetupRequestViewModel: ObservableObject {

    @Published var meetupRequests: [MeetupRequestDocument] = []
    @Published var currentMeetup: MeetupRequestDocument?
    @Published var isLoading: Bool = false
    @Published var error: String?

    private var meetupService: MeetupRequestServiceProtocol =
        MeetupRequestService()

    init() {
        if !isPreviewMode {
            Task {
                await fetchAllMeetups()
            }
        }
    }

    /// Fetch all meetup requests from the database
    func fetchAllMeetups() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let meetups =
            // try await Task.detached(priority: .userInitiated) {
                try await self.meetupService.listMeetups(queries: nil)
            // }.value
            print("meetups: \(meetups)")

            self.meetupRequests = meetups

        } catch {
            self.error = error.localizedDescription
            print(
                "MeetupRequestViewModel - fetchAllMeetups: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Fetch a specific meetup by ID
    func fetchMeetup(by id: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let meetup = try await meetupService.getMeetup(id)
            self.currentMeetup = meetup
        } catch {
            self.error = error.localizedDescription
            print(
                "MeetupRequestViewModel - fetchMeetup: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Create a new meetup request
    func createMeetup(
        title: String,
        startTime: String,
        endTime: String,
        areaId: Int,
        description: String,
        status: MeetupStatus,
        intention: MeetupIntention,
        createdByUser: UserModel,
        //        meetupApprovals: [MeetupApprovalModel] = [],
        type: MeetupType
    ) async {
        isLoading = true
        defer { isLoading = false }

        let newMeetup = MeetupRequestModel(
            title: title,
            startTime: startTime,
            endTime: endTime,
            areaId: areaId,
            description: description,
            status: status,
            intention: intention,
            createdByUser: createdByUser,
            type: type
        )

        do {
            let savedMeetup = try await meetupService.createMeetup(newMeetup)
            self.meetupRequests.append(savedMeetup)
            print("Debug - ViewModel - Successfully created meetup")
        } catch {
            self.error = error.localizedDescription
            print("Debug - ViewModel - Error creating meetup:")
            print(error)
        }
    }

    /// Update an existing meetup
    func updateMeetup(_ meetup: MeetupRequestModel) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let updatedMeetup = try await meetupService.updateMeetup(
                meetupId: meetup.id, updatedMeetup: meetup),
                let index = meetupRequests.firstIndex(where: {
                    $0.id == updatedMeetup.id
                })
            {
                meetupRequests[index] = updatedMeetup
            }
        } catch {
            self.error = error.localizedDescription
            print(
                "MeetupRequestViewModel - updateMeetup: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Delete a meetup request
    //    func deleteMeetup(_ meetup: MeetupRequestModel) async {
    //        isLoading = true
    //        defer { isLoading = false }
    //
    //        do {
    //            try await meetupService.deleteMeetup(id: meetup.title)
    //            self.meetupRequests.removeAll { $0.title == meetup.title }
    //        } catch {
    //            self.error = error.localizedDescription
    //            print(
    //                "MeetupRequestViewModel - deleteMeetup: Error: \(error.localizedDescription)"
    //            )
    //        }
    //    }

    static func iconForType(_ type: MeetupType) -> String {
        switch type {
        case .coffee: return "cup.and.saucer.fill"
        case .meal: return "fork.knife"
        case .indoorActivity: return "house.fill"
        case .outdoorActivity: return "figure.hiking"
        case .event: return "calendar"
        case .other: return "ellipsis.circle.fill"
        }
    }

    // helper function to get icon for meetup intention
    static func iconForIntention(_ intention: MeetupIntention) -> String {
        switch intention {
        case .friendship: return "figure.2"
        case .relationship: return "heart.fill"
        }
    }

    #if DEBUG
        static func mock() -> MeetupRequestViewModel {
            let meetupRequestVM = MeetupRequestViewModel()
            meetupRequestVM.meetupRequests = [
                MeetupRequestDocument.mock()
            ]

            return meetupRequestVM
        }
    #endif

}

#if DEBUG
    #Preview {
        let vm = MeetupRequestViewModel()
        vm.meetupRequests = [MeetupRequestDocument.mock()]
        return MyOrbitScreen()
    }
#endif
