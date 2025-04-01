import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    //    @State private var selectedMeetupRequest: MeetupRequestDocument? = nil
    @State private var isShowingChatRequests = false
    @State private var chatRequestListDetent: PresentationDetent = .medium
    @State private var isPendingExpanded = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                content
                    .navigationTitle(
                        "Astronauts around you"
                    )

                    .navigationBarTitleDisplayMode(
                        .automatic
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
                        NotificationsListView(
                            chatRequestListDetent: $chatRequestListDetent
                        )
                        .presentationDetents(
                            [.medium, .large], selection: $chatRequestListDetent
                        )
                        .presentationBackground(.ultraThinMaterial)
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
            }
        }
    }

    private func handleNotificationNavigation() async {
        if let requestId = appState.selectedRequestId {
            //            if let request = await chatRequestVM.getMeetUpRequest(
            //                requestId: requestId)
            //            {
            //                print("Selected request ID changed: ", requestId)
            //                isShowingChatRequests = true
            //                chatRequestListDetent = .large
            //                //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //                chatRequestVM.selectedRequest = request
            //                //                }
            //            }
            //            appState.selectedRequestId = nil  // Reset after handling
        }
    }
    @ViewBuilder private var content: some View {
        if userVM.isLoading {
            ActivityIndicatorView().padding()
        } else if let error = userVM.error {
            failedView(error)
        } else {
            loadedView()
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
            Text("\(5)")
                .font(.caption2)
                .padding(5)
                .foregroundColor(.white)
                .background(Color.red)
                .clipShape(Circle())
                .offset(x: 10, y: -10)
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

    private func loadedView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Smart search", text: $userVM.searchText)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color(.systemGray5).opacity(0.2))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )

            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(text: "Recommended", systemImage: "sparkles")
                    FilterChip(text: "Time", systemImage: "clock")
                    FilterChip(text: "Proximity", systemImage: "location")
                    Button {
                        // filter action
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .padding(10)
                            .background(ColorPalette.accent(for: colorScheme))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.bottom, 4)

            // Meetup Requests
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(meetupRequestVM.meetupRequests) { meetupRequest in
                        MeetupRequestCard(meetupRequest: meetupRequest)
                    }
                }
                .padding(.vertical)
            }
        }
        .padding(.horizontal)
        .background(ColorPalette.background(for: colorScheme))
        .refreshable {
            await meetupRequestVM.fetchAllMeetups()
        }
    }
}

struct FilterChip: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray5).opacity(0.2))
        .foregroundColor(.white)
        .cornerRadius(20)
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        @Previewable @Environment(\.colorScheme) var colorScheme

        HomeView()
            .environmentObject(AuthViewModel.mock())
            .environmentObject(UserViewModel.mock())
            .environmentObject(MeetupRequestViewModel.mock())
            .environmentObject(AppState())
            .accentColor(ColorPalette.accent(for: colorScheme))

    }
#endif
