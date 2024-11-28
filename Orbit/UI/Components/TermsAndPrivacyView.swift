//
//  TermsAndPrivacyView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-11-28.
//

import SwiftUI

struct TermsAndPrivacyView: View {
    var forButtonLabel: String  // The dynamic part of the text, e.g., 'Login'

    var body: some View {
        Text(attributedText())
            .font(.callout)  // Apply a default font to all text
            .multilineTextAlignment(.center)  // Center-align the text
    }

    private func attributedText() -> AttributedString {
        var baseText = AttributedString(
            "By clicking '\(forButtonLabel)', you agree to our ")

        // Terms & Conditions link
        var termsLink = AttributedString("Terms & Conditions")
        termsLink.foregroundColor = .accentColor
        termsLink.underlineStyle = .single
        termsLink.link = URL(string: "https://www.example.com/terms")  // Add your URL here

        baseText.append(termsLink)

        baseText.append(AttributedString(" and "))

        // Privacy Policy link
        var privacyLink = AttributedString("Privacy Policy")
        privacyLink.foregroundColor = .accentColor
        privacyLink.underlineStyle = .single
        privacyLink.link = URL(string: "https://www.example.com/privacy")  // Add your URL here

        baseText.append(privacyLink)

        return baseText
    }
}

#Preview {
    TermsAndPrivacyView(forButtonLabel: "Login")
}
