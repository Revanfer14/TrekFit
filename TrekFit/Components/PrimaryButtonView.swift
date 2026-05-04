//
//  PrimaryButtonView.swift
//  TrekFit
//
//  Component: PrimaryButtonView
//  A full-width, pill-shaped call-to-action button using the brand orange (#FF8D28).
//  Reusable across any screen that needs a primary action button.
//
//  Usage:
//    PrimaryButtonView(title: "Set Profile") {
//        viewModel.saveProfile()
//    }
//

import SwiftUI

// MARK: - PrimaryButtonView

struct PrimaryButtonView: View {

    // MARK: - Inputs

    /// The text label shown inside the button (e.g. "Set Profile")
    let title: String

    /// The closure executed when the user taps the button
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)                         // SF Pro Body Regular
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)          // stretch to full available width
                .padding(.vertical, 16)
        }
        // Background and shape applied to the Button, not the label,
        // so there is only one rendering layer — no double-ring artifact.
        .background(Color("AccentOrange"))           // #FF8D28
        .clipShape(Capsule())                        // single pill shape
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PrimaryButtonView(title: "Set Profile") {}
        .padding(.horizontal, 24)
}
