import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var chatRequestVM: ChatRequestViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedUser: UserModel? = nil
    @State private var isShowingChatRequests = false
    @State private var chatRequestListDetent: PresentationDetent = .medium
    @State private var isPendingExpanded = false

    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ZStack {
                content
                    .navigationTitle(
                        userVM.currentArea.map { "Users in \($0)" } ?? "Users"
                    )
                    .navigationBarTitleDisplayMode(.automatic)
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
                    }
                    .sheet(isPresented: $isShowingChatRequests) {
                        MeetUpRequestsListView(
                            chatRequestListDetent: $chatRequestListDetent
                        )
                        .presentationDetents(
                            [.medium, .large], selection: $chatRequestListDetent
                        )
                    }
                    .sheet(item: $selectedUser) { user in
                        ChatRequestView(
                            sender: userVM.currentUser, receiver: user)
                    }
            }
            .onAppear {
                print("appearing")
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
        } else if userVM.isOnCampus || isPreviewMode {
            loadedView(userVM.filteredUsers)
        } else {
            offCampusView()
        }
    }

    // MARK: - Buttons
    private var notificationButton: some View {
        Button(action: {
            isShowingChatRequests = true
        }) {
            Image(systemName: "bell")
                .font(.headline)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
        }
    }

    private var notificationBadge: some View {
        Group {
            if chatRequestVM.requests.count > 0 {
                Text("\(chatRequestVM.requests.count)")
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
            Task {
                await authVM.logout()
            }
        }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
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
                    .background(ColorPalette.button(for: colorScheme))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .background(ColorPalette.background(for: colorScheme))
    }

    private func offCampusView() -> some View {
        VStack {
            Text("You are currently off-campus.")
                .font(.title)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
            Text("User list is available only on campus.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .background(ColorPalette.background(for: colorScheme))
        .padding()
    }

    private func loadedView(_ users: [UserModel]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SearchBar(
                text: $userVM.searchText,
                placeholder: "Search for a user"
            )
            
            HStack{
                InterestsHorizontalTags(
                    interests: userVM.allInterests,
                    onTapInterest: { interest in
                        withAnimation {
                            userVM.toggleInterest(interest)
                        }
                    }
                )
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            
            PendingRequestsDropdown(isExpanded: $isPendingExpanded)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(userVM.filteredUsers) { user in

                        // Only show users we haven't sent requests to
                        if !chatRequestVM.requests.contains(where: { request in
                            request.data.receiverAccountId == user.accountId &&
                            request.data.senderAccountId == userVM.currentUser?.accountId &&
                            request.data.status == .pending
                        }) {
                            UserCardView(
                                user: user,
                                currentUser: userVM.currentUser
                            )
                            .onTapGesture {
                                selectedUser = user
                            }
                        }
                    }
                }
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
            .environmentObject(AppState())
    }
#endif







