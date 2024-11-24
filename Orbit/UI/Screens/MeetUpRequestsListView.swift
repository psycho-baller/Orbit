//
//  MeetUpRequestsListView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-15.
//

import SwiftUI

struct MeetUpRequestsListView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var swipedRequestId: String?
    @Binding var chatRequestListDetent: PresentationDetent

    var body: some View {
        //        NavigationStack {
        VStack {
            Text("Meetup Requests")
                .font(.headline)
                .padding()

            if let error = chatRequestVM.errorMessage {
                VStack {
                    Text("Error")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button("Retry") {
                        if let accountId = userVM.currentUser?.accountId {
                            Task {
                                await chatRequestVM.fetchRequestsForUser(
                                    userId: accountId)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            } else {
                List(chatRequestVM.requests) { request in
                    MeetUpRequestRow(request: request)
                        .onTapGesture {
                            chatRequestVM.selectedRequest = request  // Open details sheet
                            chatRequestListDetent = .large
                        }
                        //                        on close
                        .onDisappear {
                            chatRequestListDetent = .medium
                        }
                    //                    NavigationLink(
                    //                        destination: MeetUpRequestDetailsView(request: request)
                    //                    ) {
                    //                        MeetUpRequestRow(request: request)
                    //                    }
                }
                .listStyle(.plain)
            }
        }
        .sheet(item: $chatRequestVM.selectedRequest) { request in
            MeetUpRequestDetailsView(request: request)
                .environmentObject(userVM)
                .presentationDetents([.medium, .large])
        }
    }
}

// Update the MeetUpRequestRow to match the styling
struct MeetUpRequestRow: View {
    var request: ChatRequestDocument
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(
                "From: \(userVM.getUserName(from: request.data.senderAccountId))"
            )
            .font(.title)
            .padding(.bottom, 1)
            .foregroundColor(ColorPalette.text(for: colorScheme))

            Text(request.data.message)
                .font(.body)
                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
        }
        .frame(maxWidth: .infinity)

        .cornerRadius(10)
        .shadow(radius: 3)
        .swipeActions(
            edge: .leading, allowsFullSwipe: false
        ) {
            Button("Accept") {
                acceptRequest(request)
            }
            .tint(.green)
        }
        .swipeActions(
            edge: .trailing, allowsFullSwipe: false
        ) {
            Button("Decline") {
                declineRequest(request)
            }
            .tint(.red)
        }
        //        .onTapGesture {
        //
        //        }
    }
    private func acceptRequest(_ request: ChatRequestDocument) {
        Task {
            await chatRequestVM.respondToMeetUpRequest(
                requestId: request.id, response: .approved)
        }
    }

    private func declineRequest(_ request: ChatRequestDocument) {
        Task {
            await chatRequestVM.respondToMeetUpRequest(
                requestId: request.id, response: .declined)
        }
    }
}

#Preview {
    @Previewable @State var previewDetent: PresentationDetent = .medium

    MeetUpRequestsListView(chatRequestListDetent: $previewDetent)
        .environmentObject(ChatRequestViewModel())
        .environmentObject(UserViewModel.mock())
}
