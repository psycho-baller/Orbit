//
//  OnboardingView.swift
//  Orbit
//
//  Created by Ubaid Niaz on 2024-10-30.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var showProfileQuestions = false  // State to track navigation
    
    var body: some View {
        NavigationView {  // Wrap in NavigationView
            VStack(alignment: .leading, spacing: 20) {
                Text("What brings you to Orbit?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.reasons) { reason in
                            Text(reason.title)
                                .font(.headline)
                                .foregroundColor(reason.isSelected ? .white : .primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(reason.isSelected ? Color.blue : Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .onTapGesture {
                                    viewModel.toggleSelection(for: reason)
                                }
                        }
                    }
                }
                .padding(.top)

                Spacer()
                
                Button(action: {
                    showProfileQuestions = true  // Trigger navigation
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
                    NavigationLink("", destination: ProfileQuestionsView(), isActive: $showProfileQuestions)
                )
                .padding(.bottom)
            }
            .padding(.horizontal)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
