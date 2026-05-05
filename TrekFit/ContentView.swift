//
//  ContentView.swift
//  TrekFit
//
//  Root view of the app.
//  Creates the SetProfileViewModel once here (owned for the app lifetime)
//  and passes it down to LandingView → SetProfileView.
//
//  Full navigation flow:
//    LandingView
//      → SetProfileView
//          → SelectMountainView          (pick or skip mountain, saved to MountainStorage)
//              → ConnectWatchView        (pair Apple Watch)
//                  → GuideView           (friend's screen)
//                      → CountdownView   (friend's screen)
//                          → ChesterTestView (friend's screen)
//                              → ResultView  (reads ChesterTest + MountainStorage)
//

import SwiftUI

struct ContentView: View {

    /// Created once at the root — survives the entire session.
    /// Passed down via @ObservedObject so SetProfileView never recreates it.
    @StateObject private var profileViewModel = SetProfileViewModel()

    var body: some View {
        // LandingView owns the NavigationStack for the whole onboarding + test flow.
        LandingView(profileViewModel: profileViewModel)
    }
}

#Preview {
    ContentView()
}
