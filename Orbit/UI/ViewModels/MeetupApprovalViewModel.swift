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
        Task {
            await fetchApprovals()
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

    /// Reject (or remove) a meetup approval
    //    func removeApproval(_ approval: MeetupApprovalModel) async {
    //        isLoading = true
    //        defer { isLoading = false }
    //
    //        do {
    //            try await meetupApprovalService.deleteApproval(
    //                approvalId: approval.meetupRequest.title)
    //            self.approvals.removeAll {
    //                $0.meetupRequest.title == approval.meetupRequest.title
    //            }
    //        } catch {
    //            self.error = error.localizedDescription
    //            print(
    //                "MeetupApprovalViewModel - removeApproval: Error: \(error.localizedDescription)"
    //            )
    //        }
    //    }

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
