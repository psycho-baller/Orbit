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
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var swipedRequestId: String?

    var body: some View {
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
                    List {
                        ForEach(chatRequestVM.requests) { request in
                            MeetUpRequestRow(request: request)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Accept") {
                                        acceptRequest(request)
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button("Decline") {
                                        declineRequest(request)
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("Meet-Up Requests")
                    }
                }
                .onAppear {
                    Task {
                        await loadRequests()
                    }
            }
    }

    private func loadRequests() async {
        guard let currentUserId = userVM.currentUser?.accountId else {
            errorMessage = "Unable to determine the current user."
            isLoading = false
            print("Error: currentUserId is nil.")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await chatRequestVM.fetchRequestsForUser(userId: currentUserId)
            isLoading = false
            print("Requests loaded successfully: \(chatRequestVM.requests.count) requests found.")
        } catch {
            errorMessage = "Failed to load requests: \(error.localizedDescription)"
            isLoading = false
            print("Error loading requests: \(error.localizedDescription)")
        }
    }
    
    private func acceptRequest(_ request: ChatRequestDocument) {
            Task {
                await chatRequestVM.respondToMeetUpRequest(requestId: request.id, response: .approved)
            }
        }

        private func declineRequest(_ request: ChatRequestDocument) {
            Task {
                await chatRequestVM.respondToMeetUpRequest(requestId: request.id, response: .declined)
            }
        }
}

// Update the MeetUpRequestRow to match the styling
struct MeetUpRequestRow: View {
    var request: ChatRequestDocument
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("From: \(userVM.getUserName(from: request.data.senderAccountId))")
                .font(.title)
                .padding(.bottom, 1)
                .foregroundColor(ColorPalette.text(for: colorScheme))

            Text(request.data.message)
                .font(.body)
                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

