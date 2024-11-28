//
//  SocialSituationsView.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-11-07.
//


import SwiftUI

struct SocialSituationsView: View {
    @StateObject private var viewModel = SocialSituationsViewModel()
    @State private var showLifestyle = false  // State to navigate to next screen

    // Define the grid layout for three columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Social Situations & Comfort Levels")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Loop through each question
                ForEach(viewModel.questions) { question in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(question.text)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Use LazyVGrid for a multi-column layout with three columns
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(question.options) { option in
                                Text(option.title)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(option.isSelected ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(option.isSelected ? .white : .primary)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        viewModel.toggleSelection(for: option, in: question)
                                    }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Navigation button to the next screen
                Button(action: {
                    showLifestyle = true  // Navigate to next screen
                }) {
                    Text("Next")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .background(
                    NavigationLink("", destination: LifestyleView(), isActive: $showLifestyle)
                )
                .padding(.bottom)
            }
            .padding(.horizontal)
        }
    }
}



struct SocialSituationsView_Previews: PreviewProvider {
    static var previews: some View {
        SocialSituationsView()
    }
}

