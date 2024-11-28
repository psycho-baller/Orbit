import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var chatRequestVM: ChatRequestViewModel
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment

    @State private var selectedUser: UserModel? = nil
    @State private var isShowingChatRequests = false
    @State private var chatRequestListDetent: PresentationDetent = .medium
    @State private var isPendingExpanded = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ZStack {
                content
                    .navigationTitle(
                        userVM.isOnCampus || isPreviewMode
                            ? (userVM.currentArea.map { "Users in \($0)" }
                                ?? "Users")
                            : ""
                    )

                    .navigationBarTitleDisplayMode(
                        userVM.isOnCampus || isPreviewMode
                            ? .automatic : .inline
                    )
                    .toolbar {
                        // Leading toolbar: Logout button
                        ToolbarItem(placement: .navigationBarLeading) {
                            logoutButton
                        }

                        // Trailing toolbar: Notification button
                        ToolbarItem(placement: .navigationBarTrailing) {
                            notificationButton
                                .overlay(
                                    notificationBadge
                                )

                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            settingsButton
                        }
                    }
                    .sheet(isPresented: $isShowingChatRequests) {
                        MeetUpRequestsListView(
                            chatRequestListDetent: $chatRequestListDetent
                        )
                        .presentationDetents(
                            [.medium, .large], selection: $chatRequestListDetent
                        )
                        .presentationBackground(.ultraThinMaterial)
                    }
                    .sheet(item: $selectedUser) { user in
                        ChatRequestView(
                            sender: userVM.currentUser, receiver: user
                        )
                        .presentationBackground(.thinMaterial)
                        .presentationDetents(
                            [.medium, .large]
                        )
                    }
                    .sheet(isPresented: $appState.isShowingHomeSettings) {  // Present Config screen
                        HomeSettings()
                            .presentationDetents([.fraction(0.7), .large])
                            .presentationDragIndicator(.visible)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .presentationBackground(
                                colorScheme == .dark
                                    ? .thinMaterial : .ultraThinMaterial)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                //                    .background(ColorPalette.background(for: colorScheme))
            }
            .onAppear {
                Task {
                    await handleNotificationNavigation()
                }
            }
            .onChange(of: appState.selectedRequestId) {
                Task {
                    await handleNotificationNavigation()
                }
                .background(ColorPalette.background(for: colorScheme))
                .frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensure it spans the full space

    private func handleNotificationNavigation() async {
        if let requestId = appState.selectedRequestId {
            if let request = await chatRequestVM.getMeetUpRequest(
                requestId: requestId)
            {
                print("Selected request ID changed: ", requestId)
                isShowingChatRequests = true
                chatRequestListDetent = .large
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                chatRequestVM.selectedRequest = request
                //                }
            }
            appState.selectedRequestId = nil  // Reset after handling
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensure it spans the full space

        //        .background(Color.red)  // Red background for the List
    }

    @ViewBuilder private var content: some View {
        if userVM.isLoading {
            ActivityIndicatorView().padding()
        } else if let error = userVM.error {
            failedView(error)

            //        } else if userVM.currentUser?.isInterestedToMeet == false {
            //            NotInterestedToMeetView()
        } else if userVM.isOnCampus || isPreviewMode {
            loadedView(userVM.filteredUsers)
        } else {
            offCampusView()
        }
    }

    private var notificationButton: some View {
        Button(action: {
            isShowingChatRequests = true  // Show the bottom sheet
        }) {
            Image(systemName: "tray")
                .font(.headline)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
        }
    }

    private var logoutButton: some View {
        Button(action: {
            showLogoutAlert = true
        }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
        }
    }

    private func failedView(_ error: String) -> some View {
        VStack {
            Text("Error loading users")
                .font(.title)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
            Text(error)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                Task {
                    await userVM.initialize()
                }
            }) {
                Text("Retry")
                    .padding()
                    .background(ColorPalette.accent(for: colorScheme))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .background(ColorPalette.background(for: colorScheme))
    }

    private func hasPendingRequest(for user: UserModel) -> Bool {
        guard let currentUserId = userVM.currentUser?.accountId else {
            return false
        }

        return chatRequestVM.requests.contains { request in
            let receiverId = request.data.receiverAccountId
            let senderId = request.data.senderAccountId
            return receiverId == user.accountId
                && senderId == currentUserId
                && request.data.status == .pending
        }
    }

    private func loadedView(_ users: [UserModel]) -> some View {

        VStack(alignment: .leading, spacing: 0) {
            SearchBar(
                text: $userVM.searchText,
                placeholder: "Search for a user"
            )

            HStack {
                InterestsHorizontalTags(
                    interests: userVM.allInterests,
                    onTapInterest: { interest in
                        withAnimation {
                            userVM.toggleInterest(interest)
                        }
                    }
                )
            }

            PendingRequestsDropdown(isExpanded: $isPendingExpanded)
                .padding(.bottom, 16)

            if userVM.filteredUsers.isEmpty {
                NoUsersAroundView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(userVM.filteredUsers) { user in
                            if !hasPendingRequest(for: user) {
                                UserCardView(
                                    user: user,
                                    currentUser: userVM.currentUser
                                )
                                .onTapGesture {
                                    selectedUser = user
                                }
                            }
                        }
                        .cornerRadius(10)
                        .shadow(radius: 3)
                    }
                }
            }
        }
        .accentColor(ColorPalette.accent(for: colorScheme))
        .onAppear {
            if !isPreviewMode {
                Task {
                    await userVM.initialize()
                    await loadRequests()
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .background(ColorPalette.background(for: colorScheme))
    }
    private func loadRequests() async {
        guard let currentUserId = userVM.currentUser?.accountId else {
            chatRequestVM.errorMessage = "Unable to determine the current user."
            print("Error: currentUserId is nil.")
            return
        }

        print("Loading requests for user: \(currentUserId)")

        await chatRequestVM.fetchRequestsForUser(userId: currentUserId)
        print(
            "Requests loaded successfully: \(chatRequestVM.requests.count) requests found."
        )
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        HomeView()
            .environmentObject(AuthViewModel.mock())
            .environmentObject(UserViewModel.mock())
            .environmentObject(ChatRequestViewModel.mock())
    }
#endif
