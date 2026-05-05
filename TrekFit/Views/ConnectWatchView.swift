//
//  ConnectWatchView.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 01/05/26.
//  Back button updated to dismiss() so it returns to SelectMountainView correctly.
//

import SwiftUI

struct ConnectWatchView: View {
    @EnvironmentObject var profileVM: SetProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @StateObject private var hrMonitor = HeartRateMonitor()
    @State private var isAuthorized: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToGuide: Bool = false

    var body: some View {
        // HOW TO: Access box height data
        if let profile = SetProfileViewModel.loadProfile() {
            let boxHeight = profile.boxHeight
        }
        
        VStack(spacing: 0) {

            // MARK: - Custom Navigation Bar
            HStack {
                // Back button — dismisses back to SelectMountainView
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                Spacer()
                Text("Connect Watch")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            // MARK: - Main Card
            VStack(spacing: 24) {
                Text(hrMonitor.isReceivingData ? "Apple Watch Connected" : "Apple Watch not Connected")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 40)

                ZStack {
                    if isAuthorized && hrMonitor.isReceivingData {
                        HStack {
                            ZStack {
                                Image(systemName: "applewatch")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.black)
                                Image(systemName: "apple.logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.black)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 3)
                            }
                            VStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                                    .scaleEffect((hrMonitor.currentHR ?? 0) > 0 ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: hrMonitor.currentHR)
                                HStack {
                                    Text("\(Int(hrMonitor.currentHR ?? 0))")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                    Text("BPM")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    } else {
                        Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1).frame(width: 330)
                        Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1).frame(width: 260)
                        Circle().stroke(Color.gray.opacity(0.7), lineWidth: 1).frame(width: 190)
                        ZStack(alignment: .center) {
                            Image(systemName: "applewatch.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.black)
                        }
                        .padding(.leading, 5)
                    }
                }
                .frame(height: 350)

                if !isAuthorized {
                    Text("Make sure you have allowed TrekFit on your Apple Watch")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 40)
                } else if !hrMonitor.isReceivingData {
                    Text("Make sure TrekFit is open on your Apple Watch")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                        .padding(.bottom, 40)
                } else {
                    Text("Apple Watch connected successfully")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground).opacity(0.7))
            .cornerRadius(30)
            .padding(.horizontal, 24)

            Spacer()

            // MARK: - Bottom Button (3 states)
            if !isAuthorized {
                // State 1: request HealthKit permission
                Button(action: {
                    Task {
                        do {
                            try await hrMonitor.requestAuthorization()
                            isAuthorized = true
                            errorMessage = nil
                            hrMonitor.startMonitoring()
                            print("startMonitoring called")
                        } catch {
                            isAuthorized = false
                            errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    Text("Connect Apple Watch")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.orange)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)

            } else if !hrMonitor.isReceivingData {
                // State 2: authorized but waiting for first HR reading
                Button(action: {}) {
                    HStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Detecting Watch...")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.orange.opacity(0.6))
                    .cornerRadius(30)
                }
                .disabled(true)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)

            } else {
                // State 3: HR detected → go to GuideView
                Button { navigateToGuide = true } label: {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.orange)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                
            }

            if let errorMsg = errorMessage {
                Text(errorMsg)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 16)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToGuide) {
            GuideView(hrMonitor: hrMonitor)
        }
    }
}

#Preview {
    ConnectWatchView()
}
