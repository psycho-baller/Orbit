//
//  LoadingIndicator.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-25.
//


import SwiftUI

struct LoadingIndicator: ViewModifier {
    var isShowing: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                loadingView
            }
        }
    }

    private var loadingView: some View {
        GeometryReader { proxyReader in
            ZStack {
                Color.white.opacity(0.1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: .white)
                    )
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(Color.black.opacity(0.7))
                            .frame(width: 80, height: 80)
                    )
                    .position(x: proxyReader.size.width/2, y: proxyReader.size.height/2)
            }
        }
        .ignoresSafeArea()
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
    }
}

extension View {
    func loadingIndicator(_ isShowing: Bool) -> some View {
        self.modifier(LoadingIndicator(isShowing: isShowing))
    }
}