//
//  MeetUpRequestsListView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-15.
//

import SwiftUI

struct MeetUpRequestsListView: View {
    @EnvironmentObject var chatRequestVM: ChatRequestViewModel
    //    @EnvironmentObject var messagingVM: MessagingViewModel
    @EnvironmentObject var userVM: UserViewModel  // Assuming this has the current user's ID
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading requests...")
                        .padding()
                } else if let error = errorMessage {
                    VStack {
                        Text("Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()

                        Button("Retry") {
                            Task {
                                await loadRequests()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                } else {
                    List(
                        chatRequestVM.requests
                    ) { request in
                        NavigationLink(
                            destination: MeetUpRequestDetailsView(
                                request: request
                            )
                            .environmentObject(chatRequestVM)
                            //                            .environmentObject(messagingVM)
                        ) {
                            MeetUpRequestRow(request: request)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Meet-Up Requests")
            .onAppear {
                Task {
                    await loadRequests()
                }
            }
        }
    }

    // Load requests for the current user
    private func loadRequests() async {
        guard let currentUserId = userVM.currentUser?.accountId else {
            errorMessage = "Unable to determine the current user."
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await chatRequestVM.fetchRequestsForUser(userId: currentUserId)
            isLoading = false
        } catch {
            errorMessage =
                "Failed to load requests: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

// Row for displaying a single meet-up request in the list
struct MeetUpRequestRow: View {
    var request: ChatRequestDocument

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("From: \(request.data.senderAccountId)")
                    .font(.headline)
                Text(request.data.message)
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(request.data.status?.rawValue.capitalized ?? "")
                .font(.subheadline)
                .foregroundColor(
                    request.data.status == .pending
                        ? .orange
                        : (request.data.status == .approved ? .green : .red))
        }
        .padding(.vertical, 8)
    }
}
