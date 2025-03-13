//
//  MyOrbitView.swift
//  Orbit
//
//  Created by Nathaniel D'Orazio on 2025-03-09.
//

#warning ("Basic Outline to build off using hard coded data. Add navigation and real data")

import SwiftUI

struct MyOrbitView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedRequest: MeetupRequestModel?
    @State private var showDetailView = false
    @State private var isShowingCreateMeetup = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // My Posts Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("My Posts")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(Color.accentColor)
                                
                                Spacer()
                            }
                            
                            MyPostRow(
                                title: "What's your favorite food place in MacHall?",
                                tags: ["Food", "Friendship"],
                                responseCount: 2,
                                responders: ["user1", "user2"]
                            )
                        }
                        .padding(.horizontal)
                        
                        // Meetups Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Meetups")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color.accentColor)
                                .padding(.horizontal)
                            
                            MeetupRequestRow(title: "Best Prof in UofC?", time: "Today 12:00 PM", location: "MacEwan Hall", tags: ["Volunteering", "Meditation", "Bouldering"])
                                .padding(.horizontal)
                        }
                        
                        // Pending Requests Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pending Requests")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color.accentColor)
                                .padding(.horizontal)
                            
                            MeetupRequestRow(title: "What is your spirit animal?", time: "Today 16:00 PM", location: "MacEwan Hall", tags: ["Procrastinating"])
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .sheet(isPresented: $showDetailView) {
                if let request = selectedRequest {
                    MeetupRequestDetailedView(meetupRequest: request)
                }
            }
            .sheet(isPresented: $isShowingCreateMeetup) {
                CreateMeetupTypeView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingCreateMeetup = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct MyPostRow: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let tags: [String]
    let responseCount: Int
    let responders: [String]
    
    var body: some View {
        Button(action: {
            // Handle navigation
        }) {
            ZStack(alignment: .topTrailing) {
                // Main Content
                HStack(spacing: 16) {
                    // Profile Picture
                    AsyncImage(url: URL(string: "placeholder_url")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(ColorPalette.text(for: colorScheme))
                        
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ColorPalette.main(for: colorScheme))
                                    .cornerRadius(12)
                                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                            }
                            
                            Spacer()
                            
                            // Profile pictures of responders
                            HStack(spacing: -8) {
                                ForEach(responders, id: \.self) { _ in
                                    AsyncImage(url: URL(string: "placeholder_url")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 24, height: 24)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                                    }
                                }
                            }
                            
                            Text("\(responseCount) requests")
                                .font(.caption)
                                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                }
                .padding()
                
                // Notification Badge
                if responseCount > 0 {
                    Text("\(responseCount)")
                        .font(.caption2)
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: -8, y: 8)
                }
            }
            .background(ColorPalette.main(for: colorScheme))
            .cornerRadius(12)
        }
    }
}

struct MeetupRequestRow: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let time: String
    let location: String
    let tags: [String]
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "placeholder_url")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(ColorPalette.text(for: colorScheme))
                
                HStack {
                    Text(time)
                        .font(.subheadline)
                    Text("@\(location)")
                        .font(.subheadline)
                }
                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(ColorPalette.main(for: colorScheme))
                            .cornerRadius(12)
                            .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(ColorPalette.secondaryText(for: colorScheme))
        }
        .padding()
        .background(ColorPalette.main(for: colorScheme))
        .cornerRadius(12)
    }
}

#Preview {
    MyOrbitView()
}
