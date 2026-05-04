//
//  LandingView.swift
//  TrekFit
//
//  View: LandingView
//  The first screen shown when the user opens the app.
//  Displays the app brand, a tagline, a short description, and a "Jump In" CTA
//  that navigates the user to SetProfileView.
//
//  Layout (top → bottom, all overlaid on a full-screen background image):
//    1. "ReTrek" brand name        — top-left, size 34 bold, white
//    2. "Ready for the Peak?"      — title pill card, Title 1 bold, white
//    3. Body description           — body regular, white, same pill card as title
//    4. Background image           — landingPage.jpg fills the whole screen
//    5. "Jump In" button           — bottom, same orange pill as SetProfileView
//    6. Subtitle caption           — "Takes approximately 15 minutes"
//

import SwiftUI

// MARK: - LandingView

struct LandingView: View {

    // MARK: - Navigation State

    /// Flips to true when the user taps "Jump In", pushing SetProfileView onto the stack
    @State private var navigateToSetProfile: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                // ── Full-screen background image ──────────────────────────
                // landingPage.jpg placed in Assets.xcassets as "landingPage"
                Image("landingPage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // ── Foreground content overlay ────────────────────────────
                VStack(alignment: .leading, spacing: 16) {

                    // --- App brand name ---
                    // SF Pro, size 34, bold, white — top-left aligned
                    Text("ReTrek")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 60)

                    // --- Tagline card (separate from description) ---
                    Text("Ready for the Peak?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(16)
                        .background(Color(hex: "3C3C43").opacity(0.60))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    // --- Description card (separate card below, with natural spacing) ---
                    Text("ReTrek ensures you're fit and ready for your next trek. We analyze your clinical mountain fitness to give you personalized peak recommendations.")
                        .font(.body)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(16)
                        .background(Color(hex: "3C3C43").opacity(0.60))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Spacer()

                    // --- Bottom section: button + caption ---
                    VStack(spacing: 10) {

                        // "Jump In" CTA — same orange pill style as "Set Profile" button
                        PrimaryButtonView(title: "Jump In") {
                            navigateToSetProfile = true
                        }

                        // Caption below the button
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.white)

                            Text("Takes approximately 15 minutes")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)

                // Hidden NavigationLink — activated when navigateToSetProfile becomes true
                NavigationLink(
                    destination: SetProfileView(),
                    isActive: $navigateToSetProfile
                ) { EmptyView() }
            }
            // Hide the default navigation bar on this screen — it has its own brand header
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview

#Preview {
    LandingView()
}
