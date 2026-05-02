//
//  TrekFitWatchApp.swift
//  TrekFitWatch Watch App
//
//  Created by Revan Ferdinand on 01/05/26.
//

import SwiftUI

@main
struct TrekFitWatch_Watch_AppApp: App {
    @StateObject private var sessionManager = WatchSessionManager()
    
    var body: some Scene {
        WindowGroup {
            WorkoutView()
                .environmentObject(sessionManager)
        }
    }
}
