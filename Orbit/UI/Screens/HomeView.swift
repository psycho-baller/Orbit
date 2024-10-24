import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    
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
                .foregroundColor(.red)
        }
    }

    private func failedView(_ error: String) -> some View {
        VStack {
            Text("Error loading users")
                .font(.title)
                .foregroundColor(.red)
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    private func loadedView(_ users: [UserModel]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SearchBar(
                text: $userVM.searchText, placeholder: "search for a user", cancelButtonColor: .black)


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
                                    .foregroundColor(Color(hex: "#F5F5DC"))

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
                        .background(Color(hex:"#00008B"))
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
                gradient: Gradient(colors: [Color(hex: "#4A90E2"), Color(hex: "#1B3A4B")]),
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

    var body: some View {
        VStack(spacing: 20) {
            Text("Request to Chat with \(user.name)")
                .font(.title)
                .padding()

            Text("Interests: \(user.interests?.joined(separator: ", ") ?? "No interests available")")

            Button(action: {
                // Logic to send chat request goes here
            }) {
                Text("Send Chat Request")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
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
