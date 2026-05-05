//
//  ContentView.swift
//  TrekFitWatch Watch App
//
//  Created by Revan Ferdinand on 29/04/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var profileViewModel = SetProfileViewModel()

    var body: some View {
        LandingView(profileViewModel: profileViewModel)
    }
}

#Preview {
    ContentView()
}
