//
//  MeasureBoxView.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 05/05/26.
//

import SwiftUI

struct MeasureBoxView: View {
    @EnvironmentObject var store: MeasurementStore
    @EnvironmentObject var profileVM: SetProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToWatch: Bool = false
    @State private var showCameraSheet = false
    @State private var showMeasureAppAlert = false
    @FocusState private var isFocused: Bool
    
    private let presets: [Int] = [20, 30, 35, 40]
    private let accent = Color.orange
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Step Height")
                            .font(.largeTitle.bold())
                        Text("Find an elevated area or box near you to be used for a step test.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Measure with Camera Card
                    MeasureWithCameraCard {
                        Haptics.impact(.light)
                        showCameraSheet = true
                    }
                    
                    // Manual Entry
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Manual Entry")
                            .font(.title3.bold())
                        
                        ManualInputCard(
                            value: $store.stepHeight,
                            presets: presets,
                            unit: store.unit.symbol,
                            accent: accent
                        )
                    }
                    
                    // Helper Info
                    InfoBanner(text: "Chester Step Test are typically using a 30 cm elevated step.")
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .safeAreaInset(edge: .bottom) {
                ConfirmButton(title: "Confirm Step Height") {
                    confirmStepHeight()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .padding(.top, 8)
            }
            .navigationTitle("Measure Box")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(8)
                            .background(Circle().fill(Color(.systemGray6)))
                    }
                }
            }
            .sheet(isPresented: $showCameraSheet) {
                CameraMeasurementSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.clear)
            }
            .navigationDestination(isPresented: $navigateToWatch) {
                ConnectWatchView()
            }
            .alert("Measure App", isPresented: $showMeasureAppAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The Measure app is not available on this device.")
            }
        }
    }
    
    private func confirmStepHeight() {
        Haptics.notify(.success)
        
        // MeasurementStore stores in cm (e.g. 30)
        // UserProfile.boxHeight stores in meters (e.g. 0.30)
        let measuredHeight = store.stepHeight * 0.01
        
        // Save to UserProfile via ViewModel
        profileVM.updateBoxHeight(measuredHeight)
        
        navigateToWatch = true
    }
}
