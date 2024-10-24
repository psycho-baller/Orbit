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
    @State private var showingBottomSheet = false  // Controls the bottom sheet visibility
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
                    .foregroundColor(Color(hex: "#F5F5DC"))
            } else {
                Text("Loading user data...")
            }
            
            // Display selected interests
            Text("Your Interests")
                .font(.headline)
                .padding()
                .foregroundColor(Color(hex: "#F5F5DC"))
            
            GeometryReader { geometry in
                WrappingHStack(
                    items: userViewModel.currentUser?.interests ?? [],
                    availableWidth: geometry.size.width,
                    selectedInterests: .constant([]), // Display only, no selection here
                    toggleInterest: { _ in },
                    isEditing: false,
                    showingBottomSheet: $showingBottomSheet
                )
            }
            .padding()
            
        }
        .onAppear {
            // Load user's existing interests into the view
            if let interests = userViewModel.currentUser?.interests {
                selectedInterests = interests
            }
        }
        .onChange(of: userViewModel.currentUser?.interests) {
            if let interests = userViewModel.currentUser?.interests {
                selectedInterests = interests
            }
        }
        .sheet(isPresented: $showingBottomSheet, onDismiss: {
            Task {
                await userViewModel.updateUserInterests(interests: selectedInterests)
            }
        }) {
        InterestsSelectionView(
            allInterests: allInterests,
            selectedInterests: $selectedInterests,
            showingBottomSheet: $showingBottomSheet
        )
        .presentationDetents([.fraction(0.4)]) // Bottom sheet takes half the screen
    }
        .navigationTitle("Profile")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#4A90E2"), Color(hex: "#1B3A4B")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )

    }
}

// MARK: - Interests Selection View

struct InterestsSelectionView: View {
    var allInterests: [String]
    @Binding var selectedInterests: [String]
    @Binding var showingBottomSheet: Bool

    var body: some View {
        VStack {
            Text("Edit Your Interests")
                .font(.headline)
                .padding()
            
            ScrollView {
                GeometryReader { geometry in
                    WrappingHStack(
                        items: allInterests,
                        availableWidth: geometry.size.width,
                        selectedInterests: $selectedInterests,
                        toggleInterest: toggleInterest,
                        isEditing: true,
                        showingBottomSheet: $showingBottomSheet
                    )
                }
                .padding()
            }
        }
        .background(Color(hex: "#003366"))
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

// MARK: - WrappingHStack

struct WrappingHStack: View {
    var items: [String]
    var availableWidth: CGFloat
    @Binding var selectedInterests: [String]
    var toggleInterest: (String) -> Void
    var isEditing: Bool
    @Binding var showingBottomSheet: Bool

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
                (selectedInterests.contains(item) ? Color(hex: "#00008B") : Color(hex: "#ADD8E6")) :
                    Color(hex: "#00008B")
            )
            .clipShape(Capsule())
            .foregroundColor(
                isEditing ?
                (selectedInterests.contains(item) ? Color(hex: "#F5F5DC") : .black) :
                    Color(hex: "#F5F5DC"))
            .onTapGesture {
                toggleInterest(item)
                if !isEditing{
                    showingBottomSheet = true
                }
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

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel.mock())
    }
}
