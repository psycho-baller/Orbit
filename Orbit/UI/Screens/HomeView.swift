import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme  // Access color scheme from environment
    
    @State private var selectedUser: UserModel? = nil  // Track selected user for chat request
    @State private var isShowingChatRequest = false  // Control showing the chat request popup


    
    var body: some View {
        content
            .navigationBarItems(trailing: logoutButton)
            .navigationBarTitle("Users", displayMode: .inline)
            .onAppear {
                Task {
                    #if !DEBUG
                    await userVM.initialize()
                    #endif
                }
            }
            .sheet(item: $selectedUser) { user in  // Show the chat request sheet
                ChatRequestView(user: user)
            }
            .background(ColorPalette.background(for: colorScheme))
    }
    

    @ViewBuilder private var content: some View {
        if userVM.isLoading {
            ActivityIndicatorView().padding()
        } else if let error = userVM.error {
            failedView(error)

        } else {
            loadedView(userVM.filteredUsers)
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

    private func loadedView(_ users: [UserModel]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SearchBar(
                text: $userVM.searchText, placeholder: "search for a user", cancelButtonColor: .black)

            // Distance filter slider
            VStack {
                Text("Filter by Distance: \(String(format: "%.1f", userVM.selectedRadius)) km")
                    .foregroundColor(ColorPalette.text(for: colorScheme))
                Slider(value: $userVM.selectedRadius, in: 1...50, step: 1)
                    .padding(.horizontal)
                    .tint(ColorPalette.accent(for: colorScheme))
                   // .accentColor(ColorPalette.)
                }
            
            // Horizontal tags for filtering by interests
            InterestsHorizontalTags(
                interests: userVM.allInterests,
                onTapInterest: { interest in
                    withAnimation {
                        userVM.toggleInterest(interest)
                    }
                }
            )
            .padding(.vertical, 8)
            .background(Color.clear)
            .cornerRadius(10)
            .shadow(radius: 3)

            // List of users
            ScrollView {
                LazyVStack(spacing: 16) {  // Using LazyVStack for efficient loading and spacing
                    ForEach(users) { user in
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(user.name)
                                    .font(.title)
                                    .padding(.bottom, 1)
                                    .foregroundColor(ColorPalette.text(for: colorScheme))

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
                            //                            Spacer()  // Pushes the content to the leading edge
                        }
                        .padding()
                        .background(.ultraThinMaterial)  // Apply the translucent background effect here
                        .background(ColorPalette.main(for: colorScheme))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .onTapGesture {
                            selectedUser = user  // Set the selected user
                        }
                        //                        .padding(.vertical)  // Add padding on the sides to space it from screen edges
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 60)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [ColorPalette.background(for: colorScheme), ColorPalette.main(for: colorScheme)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
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

            Text("Interests: \(user.interests?.joined(separator: ", ") ?? "No interests available")")
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel.mock())
    }
}
