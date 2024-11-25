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
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ZStack {
                content
                    .navigationTitle(
                        userVM.isOnCampus
                            ? (userVM.currentArea.map { "Users in \($0)" }
                                ?? "Users")
                            : ""
                    )

                    .navigationBarTitleDisplayMode(
                        userVM.isOnCampus ? .automatic : .inline
                    )
                    .navigationBarItems(
                        trailing: HStack {
                            logoutButton
                            notificationButton
                                .overlay(
                                    notificationBadge
                                )
                            settingsButton

                        }
                    )
                    .sheet(isPresented: $isShowingChatRequests) {
                        MeetUpRequestsListView(
                            chatRequestListDetent: $chatRequestListDetent
                        )
                        .presentationDetents(
                            [.medium, .large], selection: $chatRequestListDetent
                        )
                        .presentationDragIndicator(.visible)
                    }
                    .sheet(item: $selectedUser) { user in
                        ChatRequestView(
                            sender: userVM.currentUser, receiver: user)
                    }
                    .sheet(isPresented: $appState.isShowingHomeSettings) {  // Present Config screen
                        HomeSettings()
                            .presentationDetents([.fraction(0.7), .large])
                            .presentationDragIndicator(.visible)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ColorPalette.background(for: colorScheme))
            }
            .onAppear {
                Task {
                    await handleNotificationNavigation()
                }
            }
            .onChange(of: appState.selectedRequestId) { _ in
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
                print("Selected request ID changed: ", requestId ?? "nil")
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
        } else if userVM.isOnCampus {
            loadedView(userVM.filteredUsers)
        } else {
            OffCampusView()
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
            showLogoutAlert = true
            Task {
                await authVM.logout()
            }
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
                    .background(ColorPalette.button(for: colorScheme))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .background(ColorPalette.background(for: colorScheme))
    }

    private func loadedView(_ users: [UserModel]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchBar(
                text: $userVM.searchText, placeholder: "Search for a user"
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
                .cornerRadius(10)
                .shadow(radius: 3)
            }

            if userVM.filteredUsers.isEmpty {
                NoUsersAroundView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(userVM.filteredUsers) { user in
                            UserCardView(
                                user: user, currentUser: userVM.currentUser
                            )
                            .onTapGesture {
                                selectedUser = user
                            }
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    if !isPreviewMode {
                        Task {
                            await userVM.initialize()
                            await loadRequests()
                        }
                    }
                }
            }
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
