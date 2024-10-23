//
//  ProfileView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2024-10-19.
//

import SwiftUI

struct ProfileView: View {
    @State private var allInterests = ["Basketball", "Video Games", "Music", "Reading", "Cooking", "Art", "Travel", "Movies"] // Sample interests
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditing = false  // Controls the edit mode
    @State private var selectedInterests: [String] = []  // Temporary storage for edited interests

    var body: some View {
        VStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .padding()
            
            
            // Display user's name
            if let name = userViewModel.currentUser?.name {
                Text(name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            } else {
                Text("Loading user data...")
            }
            
            // Interest section
            if isEditing {
                Text("Edit Your Interests")
                    .font(.headline)
                    .padding()

                // Wrapping layout for interests
                GeometryReader { geometry in
                    WrappingHStack(items: allInterests, availableWidth: geometry.size.width, selectedInterests: $selectedInterests, toggleInterest: toggleInterest, isEditing: true)
                }
                .padding()

                Button(action: {
                    // Save selected interests to the user's profile
                    Task{
                        await userViewModel.updateUserInterests(interests: selectedInterests)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isEditing = false
                        }
                    }
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                .padding()

            } else {
                // Display selected interests when not editing
                Text("Your Interests")
                    .font(.headline)
                    .padding()

                GeometryReader { geometry in
                    WrappingHStack(items: userViewModel.currentUser?.interests ?? [], availableWidth: geometry.size.width, selectedInterests: .constant([]), toggleInterest: { _ in }, isEditing: false)
                }
                .padding()

                Button(action: {
                    // Enter edit mode
                    selectedInterests = userViewModel.currentUser?.interests ?? []  // Load user's current interests into the editable list
                    isEditing = true
                }) {
                    Text("Edit")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }

        .onAppear {
            // Load user's existing interests into the view
            if let interests = userViewModel.currentUser?.interests {
                selectedInterests = interests
            }
        }
        .onChange(of: userViewModel.currentUser?.interests){
            if let interests = userViewModel.currentUser?.interests {
                selectedInterests = interests
            }
        }
        .navigationTitle("Profile")
    }
    
    // Toggle the selected interest
    func toggleInterest(_ interest: String) {
        if let index = selectedInterests.firstIndex(of: interest) {
            selectedInterests.remove(at: index)  // Remove if already selected
        } else {
            selectedInterests.append(interest)  // Add if not already selected
        }
    }
}
    

struct WrappingHStack: View {
    var items: [String]
    var availableWidth: CGFloat
    @Binding var selectedInterests: [String]
    var toggleInterest: (String) -> Void
    var isEditing: Bool

    @State private var totalHeight = CGFloat.zero  // Tracks total height

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)  // Set the height to match the content
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                itemView(for: item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > availableWidth) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == self.items.last! {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == self.items.last! {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func itemView(for item: String) -> some View {
        Text(item)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                isEditing ?
                (selectedInterests.contains(item) ? Color.blue : Color.gray.opacity(0.2)) :
                    Color.blue
            )
            .clipShape(Capsule())
            .foregroundColor(selectedInterests.contains(item) ? .white : .black)
            .onTapGesture {
                toggleInterest(item)
            }
    }

    // Helper to track view height
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geo.size.height
            }
            return Color.clear
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel.mock())
    }
}

