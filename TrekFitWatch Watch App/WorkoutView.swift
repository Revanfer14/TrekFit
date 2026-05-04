//
//  WorkoutView.swift
//  TrekFitWatch Watch App
//
//  Created by Revan Ferdinand on 01/05/26.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var sessionManager: WatchSessionManager
    
    var body: some View {
        VStack(spacing: 12) {
            if sessionManager.currentHR > 0 {
                Text("\(Int(sessionManager.currentHR))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.red)
                Text("bpm")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if sessionManager.isStarting {
                ProgressView()
                    .progressViewStyle(.circular)
                Text("Detecting..")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            } else {
                Text("–")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            if sessionManager.isStarting {
                Button {
                    
                } label: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                }
                .disabled(true)
                .tint(.gray)
            } else {
                Button(sessionManager.isRunning ? "Stop" : "Start") {
                    Task {
                        if sessionManager.isRunning {
                            await sessionManager.stopWorkout()
                        } else {
                            await sessionManager.startWorkout()
                        }
                    }
                }
                .tint(sessionManager.isRunning ? .red : .green)
            }
        }
    }
}
