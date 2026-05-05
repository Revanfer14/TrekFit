//
//  TrekFitApp.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 29/04/26.
//

import SwiftUI
import SwiftData

@main
struct TrekFitApp: App {
    @StateObject private var measurementStore = MeasurementStore()
    @StateObject private var profileViewModel = SetProfileViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(measurementStore)
                .environmentObject(profileViewModel)
        }
    }
}
