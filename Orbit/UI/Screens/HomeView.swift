import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var chatRequestVM: ChatRequestViewModel
<<<<<<< HEAD
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment

    @State private var selectedUser: UserModel? = nil  // Track selected user for chat request
    @State private var isShowingChatRequests = false  // Control showing the chat request popup

    var body: some View {
        ZStack {
            content
                .navigationBarItems(
                    trailing: HStack {
                        logoutButton
                        notificationButton
                            .overlay(
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
                            )
                    }
                )
                .navigationBarTitle(
                    userVM.currentArea.map { "Users in \($0)" } ?? "Users",
                    displayMode: .automatic
                )
                .sheet(isPresented: $isShowingChatRequests) {  // Present as bottom sheet
                    MeetUpRequestsListView()
                        .environmentObject(chatRequestVM)
                        .environmentObject(userVM)
                        .presentationDetents([.medium, .large])  // Adjustable heights
                        .presentationDragIndicator(.visible)  // Drag indicator for resizing
                }
                .sheet(item: $selectedUser) { user in  // Show the chat request sheet
                    ChatRequestView(sender: userVM.currentUser, receiver: user)
                }
                .background(ColorPalette.background(for: colorScheme))
                .frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensure it spans the full space

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensure it spans the full space

        //        .background(Color.red)  // Red background for the List
    }

=======
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
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
    @ViewBuilder private var content: some View {
        if userVM.isLoading {
            ActivityIndicatorView().padding()
        } else if let error = userVM.error {
            failedView(error)
<<<<<<< HEAD
        } else if userVM.isOnCampus || isPreviewMode {
            loadedView(userVM.filteredUsers)
        } else {
            offCampusView()
        }
    }

    private var notificationButton: some View {
        Button(action: {
            isShowingChatRequests = true  // Show the bottom sheet
=======
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
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
        }) {
            Image(systemName: "bell")
                .font(.headline)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
        }
    }

<<<<<<< HEAD
    private var logoutButton: some View {
        Button(action: {
=======
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
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
            Task {
                await authVM.logout()
            }
        }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .foregroundColor(ColorPalette.accent(for: colorScheme))
        }
<<<<<<< HEAD
    }

=======
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
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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

<<<<<<< HEAD
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
        VStack(alignment: .leading, spacing: 0) {
            SearchBar(
                text: $userVM.searchText, placeholder: "search for a user"
=======
    private func loadedView(_ users: [UserModel]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchBar(
                text: $userVM.searchText, placeholder: "Search for a user"
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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

<<<<<<< HEAD
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
                .background(
                    ColorPalette.background(for: colorScheme)
                    //                    LinearGradient(
                    //                        gradient: Gradient(colors: [
                    //                            ColorPalette.background(for: colorScheme),
                    //                            ColorPalette.main(for: colorScheme),
                    //                        ]),
                    //                        startPoint: .topLeading,
                    //                        endPoint: .bottomTrailing
                    //                    )
                ).onAppear {
                    if !isPreviewMode {
                        Task {
                            await userVM.initialize()
                            await loadRequests()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
=======
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
            }
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

>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
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
<<<<<<< HEAD
=======
            .environmentObject(AppState())
>>>>>>> 9b6bc2c846a02363d4b56dec9632693ab73e3aac
    }
#endif
