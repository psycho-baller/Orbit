import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var meetupRequestVM: MeetupRequestViewModel
    @EnvironmentObject private var chatVM: ChatViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    @State private var isShowingChatRequests = false
    @State private var chatRequestListDetent: PresentationDetent = .medium
    @State private var isPendingExpanded = false
    @State private var showLogoutAlert = false
    @State private var selectedSortingOption: SortingOptions = .recommended
    @State private var isListReversed: Bool = false

    // MARK: - Home Filter & Sorting Options
    enum SortingOptions: String, CaseIterable, Identifiable {
        case recommended = "Recommended"
        case time = "Time"
        case proximity = "Proximity"

        var id: String { rawValue }

        var iconName: String {
            switch self {
            case .recommended: return "sparkles"
            case .time: return "clock"
            case .proximity: return "location.fill"
            }
        }
    }

    @ViewBuilder
    private func searchAndFilterBar() -> some View {
        VStack(spacing: 4) {
            SearchBar(
                text: $userVM.searchText,
                placeholder: "Smart Search"
            )
            .padding(.top, 8)

            HStack(spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.accentColor)
                        .padding(2)

                    HStack(spacing: 10) {
                        ForEach(SortingOptions.allCases) { option in
                            let isSelected = option == selectedSortingOption
                            let bgColor =
                                isSelected
                                ? ColorPalette.accent(for: colorScheme).opacity(
                                    0.7
                                )
                                : ColorPalette.background(for: colorScheme)
                                    .opacity(0.9)

                            let textColor =
                                isSelected
                                ? Color.white
                                : ColorPalette.text(for: colorScheme).opacity(
                                    0.85
                                )

                            Button(action: {
                                withAnimation {
                                    selectedSortingOption = option
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: option.iconName)
                                        .font(.system(size: 14))

                                    if isSelected {
                                        Text(option.rawValue)
                                            .font(
                                                .system(
                                                    size: 13,
                                                    weight: .semibold
                                                )
                                            )
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .minimumScaleFactor(0.9)
                                            .layoutPriority(1)
                                            .transition(
                                                .opacity.combined(with: .scale)
                                            )
                                    }
                                }
                                .padding(
                                    .horizontal,
                                    selectedSortingOption == .recommended
                                        ? 14 : 24
                                )
                                .frame(
                                    maxWidth: isSelected ? .infinity : nil,
                                    alignment: .center
                                )
                                //                                .padding(.horizontal, 4)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(bgColor)
                                )
                                .foregroundColor(textColor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            ColorPalette.secondaryText(for: colorScheme)
                                .opacity(0.15)
                        )
                )

                // 2. OUTSIDE the background: Rightmost icon
                Button(action: {
                    // show advanced filters maybe?
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.accentColor)
                        .padding(10)
                }
            }
        }
    }

    @ViewBuilder
    private func meetupCardList() -> some View {
        ScrollView {
            VStack(spacing: 12) {
                LazyVStack(spacing: 12) {
                    ForEach(
                        isListReversed
                            ? meetupRequestVM.filteredMeetupRequests(
                                for: userVM.currentUser
                            ).reversed()
                            : meetupRequestVM.filteredMeetupRequests(
                                for: userVM.currentUser
                            )
                    ) { meetupRequest in
                        MeetupRequestCardView(meetupRequest: meetupRequest)
                    }
                }
            }
            .padding(.horizontal)

        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                content
                    .navigationTitle(
                        "Meetups around you"
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
                            [.medium, .large],
                            selection: $chatRequestListDetent
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
                                    ? .thinMaterial : .ultraThinMaterial
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ColorPalette.background(for: colorScheme))
            }
            .onAppear {
                Task {
                    await handleNotificationNavigation()
                }
            }
            .onChange(of: appState.selectedChatId) {
                Task {
                    await handleNotificationNavigation()
                }
            }
        }
    }

    private func handleNotificationNavigation() async {
        if let chatId = appState.selectedChatId,
            let chatDocumentToNavigateTo = await chatVM.getChatDocument(
                chatId: chatId
            )
        {
            self.appState.selectedTab = .chats
            self.appState.messagesNavigationPath.append(
                chatDocumentToNavigateTo
            )
            appState.selectedChatId = nil
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
        VStack(alignment: .leading, spacing: 10) {
            searchAndFilterBar()
                .padding(.horizontal)

            meetupCardList()
        }
        .background(ColorPalette.background(for: colorScheme))
        .refreshable {
            await meetupRequestVM.fetchAllMeetups()
        }
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
