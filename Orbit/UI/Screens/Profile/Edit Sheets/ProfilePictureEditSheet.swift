//
//  ProfilePictureEditSheet.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-29.
//

#warning ("TODO: Make it work to change profile picture")

import SwiftUI
import PhotosUI

struct ProfilePictureEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userVM: UserViewModel
    
    let user: UserModel
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Update your profile picture")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                
                // Current profile picture or selected image
                ZStack {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2))
                    } else if let profilePictureUrl = user.profilePictureUrl, !profilePictureUrl.isEmpty {
                        AsyncImage(url: URL(string: profilePictureUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            .overlay(Circle().stroke(ColorPalette.accent(for: colorScheme), lineWidth: 2))
                    }
                }
                .padding()
                
            }
            .padding(.top)
            .navigationTitle("Edit Profile Picture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
            }
        }
    }
} 
