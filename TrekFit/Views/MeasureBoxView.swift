//
//  MeasureBoxView.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 05/05/26.
//


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
    @State private var manualText: String = ""
    @State private var showMeasureAppAlert = false
    @FocusState private var isFocused: Bool
    
    private let presets: [Int] = [20, 30, 35, 40]
    private let accent = Color.orange
    
    var body: some View {
        let _ = print("🏔️ navigateToWatch: \(navigateToWatch)")
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Step Height")
                            .font(.largeTitle.bold())
                        Text("Find a elevated area or box near you to be used for a step test.")
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
                    Haptics.notify(.success)
                    navigateToWatch = true
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Measure Box")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
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
    
    private func openMeasureApp() {
        Haptics.impact(.light)
        
        // URL Scheme untuk membuka Apple Measure App
        if let url = URL(string: "https://apps.apple.com/app/measure/id1383426740") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback: coba buka via App Store atau tampilkan alert
                showMeasureAppAlert = true
            }
        }
    }
    
    private func confirmStepHeight() {
        Haptics.notify(.success)
        
        // MeasurementStore menyimpan dalam cm (e.g. 30)
        // UserProfile.boxHeight menyimpan dalam meter (e.g. 0.30)
        let measureHeightResult = store.stepHeight
        
        // Simpan ke UserProfile via ViewModel
        profileVM.updateBoxHeight(measureHeightResult)
        
        navigateToWatch = true
    }
}

// MARK: - Open Measure App Button Component
struct OpenMeasureAppButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "ruler.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Measure with Apple Measure")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Use Apple's built-in Measure app")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square.fill")
                    .font(.title3)
                    .foregroundStyle(.green.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MeasureBoxView()
        .environmentObject(MeasurementStore())
        .environmentObject(SetProfileViewModel())
}
