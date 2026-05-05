//
//  ContentView.swift
//  TrekFitWatch Watch App
//
//  Created by Revan Ferdinand on 29/04/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var profileViewModel = SetProfileViewModel()
    
    /// Cek sekali saat launch apakah profile sudah pernah disimpan
    private var isReturningUser: Bool {
        UserDefaults.standard.data(forKey: "saved_user_profile") != nil
    }
    
    var body: some View {
        if isReturningUser {
            NavigationStack {
                HistoryLogView()
            }
        } else {
            LandingView(profileViewModel: profileViewModel)
        }
    }
}

#Preview {
    ContentView()
}
