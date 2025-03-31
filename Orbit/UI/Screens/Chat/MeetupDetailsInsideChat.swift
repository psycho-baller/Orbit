struct MeetupDetailsInsideChat: View {
    let user: UserModel
    /// Determines whether to show profile image and full name (when true)
    /// or just the username (when false).
    let showFullDetails: Bool

    var body: some View {
        VStack(spacing: 20) {
            if showFullDetails {
                AsyncImage(url: URL(string: user.profilePictureUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                }
                Text("\(user.firstName) \(user.lastName ?? "")")
                    .font(.title)
                    .foregroundColor(.accentColor)
            } else {
                Text(user.username)
                    .font(.title)
                    .foregroundColor(.accentColor)
            }
            // Additional user details can be added here.
            Spacer()
        }
        .padding()
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
    }
}