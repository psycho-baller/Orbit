//
//  MeetupApprovalViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2025-02-20.
//

import SwiftUI

@MainActor
class MeetupApprovalViewModel: ObservableObject {
    @Published var approvals: [MeetupApprovalDocument] = []
    @Published var isLoading = false
    @Published var error: String?

    private var meetupApprovalService: MeetupApprovalServiceProtocol =
        MeetupApprovalService()

    init() {
        if !isPreviewMode {
            Task {
                await fetchApprovals()
            }
        }
    }

    /// Fetch all approvals from the database
    func fetchApprovals() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedApprovals =
                try await meetupApprovalService.listApprovals(queries: nil)
            self.approvals = fetchedApprovals
        } catch {
            self.error = error.localizedDescription
            print(
                "MeetupApprovalViewModel - fetchApprovals: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Approve a meetup request
    func approveMeetup(
        approval: MeetupApprovalModel
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let savedApproval = try await meetupApprovalService.createApproval(
                approval: approval)
            self.approvals.append(savedApproval)
        } catch {
            self.error = error.localizedDescription
            print(
                "MeetupApprovalViewModel - approveMeetup: Error: \(error.localizedDescription)"
            )
        }
    }

    /// Update an existing meetup approval
    func updateMeetupApproval(_ approval: MeetupApprovalDocument) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let updatedApproval =
                try await meetupApprovalService.updateApproval(
                    approvalId: approval.id, updatedApproval: approval.data
                ),
                let index = approvals.firstIndex(where: {
                    $0.id == updatedApproval.id
                })
            {
                approvals[index] = updatedApproval
            }
        } catch {
            self.error = error.localizedDescription
            print(
                "MeetupApprovalViewModel - updateMeetupApproval: Error: \(error.localizedDescription)"
            )
        }
    }
    /// Declines (removes) a meetup approval request
    func declineMeetup(meetupRequest: MeetupRequestModel) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Find the approval linked to this meetup request
            if let approval = approvals.first(where: { $0.data.meetupRequest?.id == meetupRequest.id }) {
                // Call the service to delete it
                try await meetupApprovalService.deleteApproval(approvalId: approval.id)

                // Update UI by removing the declined approval
                await MainActor.run {
                    self.approvals.removeAll { $0.id == approval.id }
                }

                print("Successfully declined meetup request.")
            } else {
                print("Error: Approval not found for meetup request \(meetupRequest.id)")
            }
        } catch {
            self.error = error.localizedDescription
            print("MeetupApprovalViewModel - declineMeetup: Error: \(error.localizedDescription)")
        }
    }

    #if DEBUG
        static func mock() -> MeetupApprovalViewModel {
            let meetupRequestVM = MeetupApprovalViewModel()
            meetupRequestVM.approvals = [
                MeetupApprovalDocument.mock()
            ]
            return meetupRequestVM
        }
    #endif
}

