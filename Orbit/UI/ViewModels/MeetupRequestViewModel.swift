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
            let meetups = try await meetupService.listMeetups(queries: nil)
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
        createdBy: UserModel,
        meetupApprovals: [MeetupApprovalModel] = [],
        type: MeetupType
    ) async {
        isLoading = true
        defer { isLoading = false }

        print("Debug - ViewModel - Creating meetup with data:")
        print("createdBy: \(createdBy)")
        
        let newMeetup = MeetupRequestModel(
            title: title,
            startTime: startTime,
            endTime: endTime,
            areaId: areaId,
            description: description,
            status: status,
            intention: intention,
            createdBy: createdBy,
            meetupApprovals: meetupApprovals,
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
    func updateMeetup(_ meetup: MeetupRequestDocument) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let updatedMeetup = try await meetupService.updateMeetup(
                meetupId: meetup.id, updatedMeetup: meetup.data),
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
