import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject private var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var userVM: UserViewModel

    //    @State private var selectedMeetupRequest: MeetupRequestDocument? = nil
    @State private var isShowingChatRequests = false
    @State private var chatRequestListDetent: PresentationDetent = .medium
    @State private var isPendingExpanded = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                content
                    .navigationTitle(
                        "Astronauts around you"
                        //                        userVM.isOnCampus || isPreviewMode
                        //                            ? (userVM.currentArea.map { "\($0)" }
                        //                                ?? "Astronauts around you")
                        //                            : ""
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
                    //                    .sheet(item: $selectedMeetupRequest) { meetupRequest in
                    //                        ZStack {
                    //                            ScrollView {
                    //
                    //                                //                                .padding(.bottom, 80)
                    //                            }
                    //                        }
                    //                        .presentationDetents([.large])
                    //                        .presentationDragIndicator(.visible)
                    //                    }
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
            }
        }
    }

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
    }
    @ViewBuilder private var content: some View {
        if userVM.isLoading {
            ActivityIndicatorView().padding()
        } else if let error = userVM.error {
            failedView(error)
            //        } else if userVM.currentUser?.isInterestedToMeet == false {
            //            NotInterestedToMeetView()
            //        } else {
            //            OffCampusView()
        }
        loadedView()
    }

    // MARK: - Buttons
    private var notificationButton: some View {
        Button(action: {
            isShowingChatRequests = true
        }) {
            Image(systemName: "tray")
                .font(.headline)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
        }
    }

    private var notificationBadge: some View {
        Group {
            if chatRequestVM.incomingRequests.count > 0 {
                Text("\(chatRequestVM.incomingRequests.count)")
                    .font(.caption2)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 10, y: -10)
            }
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
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("Confirm Logout"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Logout")) {
                    Task {
                        await authVM.logout()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var settingsButton: some View {
        Button(action: {
            appState.isShowingHomeSettings = true
        }) {
            Image(systemName: "gearshape")
                .font(.headline)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
        }
    }

    // MARK: - Views
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

    private func hasPendingRequest(for userInQuestion: UserModel) -> Bool {
        guard let currentUserId = userVM.currentUser?.accountId else {
            return false
        }

        return chatRequestVM.requests.contains { request in
            let requestReceiverId = request.data.receiverAccountId
            let requestSenderId = request.data.senderAccountId
            return requestReceiverId == userInQuestion.accountId
                && requestSenderId == currentUserId
                && request.data.status == .pending
        }
    }

    private func loadedView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchBar(
                text: $userVM.searchText,
                placeholder: "Search for a meetup request"
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

            //            PendingRequestsDropdown(isExpanded: $isPendingExpanded)
            //                .padding(.bottom, 16)

//            if userVM.filteredUsers.isEmpty {
//                NoUsersAroundView()
//            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(meetupRequestVM.meetupRequests) { meetupRequest in
                            MeetupRequestCardView(meetupRequest: meetupRequest.data)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
//        }
        .onAppear {
            if !isPreviewMode {
                Task {
                    await userVM.initialize()
                    await loadRequests()
                }
            }
        }
        .padding(.horizontal)
        .background(ColorPalette.background(for: colorScheme))
        .refreshable {
            await meetupRequestVM.fetchAllMeetups()
        }
    }

    private func loadRequests() async {
        guard let currentUserId = userVM.currentUser?.accountId else {
            chatRequestVM.errorMessage = "Unable to determine the current user."
            print("Error: currentUserId is nil.")
            return
        }

        print("Loading requests for user: \(currentUserId)")
        await chatRequestVM.fetchRequestsForUser(userId: currentUserId)
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme

        HomeView()
            .environmentObject(AuthViewModel.mock())
            .environmentObject(UserViewModel.mock())
            .environmentObject(ChatRequestViewModel.mock())
            .environmentObject(MeetupRequestViewModel.mock())
            .environmentObject(AppState())
            .accentColor(ColorPalette.accent(for: colorScheme))

    }
#endif
