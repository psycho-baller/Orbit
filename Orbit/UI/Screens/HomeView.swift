import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment

    @State private var selectedUser: UserModel? = nil  // Track selected user for chat request
    @State private var isShowingChatRequest = false  // Control showing the chat request popup
    @State private var isMenuExpanded = false

    var body: some View {
        ZStack {
            content
                .navigationBarItems(trailing: logoutButton)
                .navigationBarTitle(
                    userVM.currentArea.map { "Users in \($0)" } ?? "Users",
                    displayMode: .inline
                )
                .sheet(item: $selectedUser) { user in  // Show the chat request sheet
                    ChatRequestView(user: user)
                }
                .background(ColorPalette.background(for: colorScheme))

            // Overlay to detect taps outside the menu
            if isMenuExpanded {
                Color.clear
                    .contentShape(Rectangle())  // Make the entire area tappable
                    .onTapGesture {
                        withAnimation {
                            isMenuExpanded = false  // Collapse the menu when tapping outside
                        }
                    }
            }
        }
    }

    @ViewBuilder private var content: some View {
        if userVM.isLoading {
            ActivityIndicatorView().padding()
        } else if let error = userVM.error {
            failedView(error)
        } else if userVM.isOnCampus {
            loadedView(userVM.filteredUsers)
        } else {
            offCampusView()
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
        VStack(alignment: .leading, spacing: 2) {
            SearchBar(
                text: $userVM.searchText, placeholder: "search for a user"
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
                .background(Color.clear)
                .cornerRadius(10)
                .shadow(radius: 3)

                CustomMenu(
                    alignment: .trailing,
                    isExpanded: $isMenuExpanded,
                    label: {
                        // Using an icon instead of text
                        Image(systemName: "slider.horizontal.3")  // Suitable icon for slider
                            .resizable()
                            .frame(width: 24, height: 24)  // Adjust size as needed
                            .foregroundColor(
                                ColorPalette.accent(for: colorScheme)
                            )
                            .padding(.trailing, 8)
                            .background(
                                ColorPalette.background(for: colorScheme)
                            )
                            .cornerRadius(8)
                    }
                ) {
                    VStack {
                        Text(
                            "\(String(format: "%.1f", userVM.selectedRadius)) km"
                        )
                        .foregroundColor(ColorPalette.text(for: colorScheme))

                        Slider(
                            value: $userVM.selectedRadius, in: 1...60, step: 1
                        )
                        .tint(ColorPalette.accent(for: colorScheme))
                        .frame(width: 150)
                    }
                }
            }

            // List of users
            ScrollView {
                LazyVStack(spacing: 16) {  // Using LazyVStack for efficient loading and spacing
                    ForEach(users) { user in
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(user.name)
                                    .font(.title)
                                    .padding(.bottom, 1)
                                    .foregroundColor(
                                        ColorPalette.text(for: colorScheme))

                                // user-specific interests tags
                                InterestsHorizontalTags(
                                    interests: user.interests ?? [],
                                    onTapInterest: { interest in
                                        withAnimation {
                                            userVM.toggleInterest(interest)
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)  // Apply the translucent background effect here
                        .background(ColorPalette.main(for: colorScheme))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .onTapGesture {
                            selectedUser = user  // Set the selected user
                        }
                    }
                }
            }
            .disabled(isMenuExpanded)  // Disable interaction with ScrollView when menu is expanded
            .padding(.horizontal)
            .padding(.bottom, 60)
            .zIndex(-1)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    ColorPalette.background(for: colorScheme),
                    ColorPalette.main(for: colorScheme),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ).onAppear {
            Task {
                #if !PREVIEW
                    await userVM.initialize()
                #endif
            }
        }
    }
}

// MARK: - Chat Request View
struct ChatRequestView: View {
    let user: UserModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment

    var body: some View {
        VStack(spacing: 20) {
            Text("Request to Chat with \(user.name)")
                .font(.title)
                .padding()
                .foregroundColor(ColorPalette.text(for: colorScheme))

            Text(
                "Interests: \(user.interests?.joined(separator: ", ") ?? "No interests available")"
            )
            .foregroundColor(ColorPalette.text(for: colorScheme))

            Button(action: {
                // Logic to send chat request goes here
            }) {
                Text("Send Chat Request")
                    .foregroundColor(ColorPalette.text(for: colorScheme))
                    .padding()
                    .background(ColorPalette.button(for: colorScheme))
                    .cornerRadius(10)
            }

            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(ColorPalette.accent(for: colorScheme))
                    .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.background(for: colorScheme))
        .cornerRadius(15)
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel.mock())
    }
#endif
