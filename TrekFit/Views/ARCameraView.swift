//
//  ARCameraView.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 04/05/26.
//

import SwiftUI
import ARKit
import RealityKit

// MARK: - ARView UIViewRepresentable

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var session: ARMeasurementSession

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false
        session.setup(arView: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

// MARK: - Camera Bottom Sheet

struct CameraBottomSheet: View {
    @ObservedObject var store: MeasurementStore
    @StateObject private var arSession = ARMeasurementSession()
    @Binding var isPresented: Bool

    @State private var showConfirmButton = false
    @State private var animateResult = false

    var body: some View {
        NavigationView {
            ZStack {
                // AR Camera
                ARViewContainer(session: arSession)
                    .ignoresSafeArea()

                // Overlay
                VStack {
                    Spacer()

                    // Crosshair
                    crosshairView

                    Spacer()

                    // Status + Controls
                    measurementControlsCard
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, .white.opacity(0.3))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Measure Height")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .alert("Error", isPresented: .constant(arSession.showError != nil)) {
            Button("OK") { arSession.showError = nil }
        } message: {
            Text(arSession.showError ?? "")
        }
        .onChange(of: arSession.measuredHeightCM) { newVal in
            if newVal != nil {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    animateResult = true
                    showConfirmButton = true
                }
            }
        }
    }

    // MARK: - Crosshair
    private var crosshairView: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                .frame(width: 60, height: 60)

            // Center dot
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)

            // Step indicators
            if arSession.bottomAnchorPlaced {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("TOP")
                        .font(.caption2.bold())
                        .foregroundColor(.orange)
                }
                .offset(y: -50)
            }
        }
    }

    // MARK: - Measurement Controls Card
    private var measurementControlsCard: some View {
        VStack(spacing: 16) {

            // Step progress indicators
            stepProgressView

            // Status text
            Text(arSession.statusMessage)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            // Result Display
            if let height = arSession.measuredHeightCM {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", height))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(animateResult ? 1.0 : 0.8)

                    Text("cm")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .transition(.scale.combined(with: .opacity))
            }

            // Buttons
            HStack(spacing: 12) {
                // Reset button
                Button {
                    withAnimation {
                        arSession.reset()
                        animateResult = false
                        showConfirmButton = false
                    }
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.2), in: Capsule())
                }

                // Confirm button (shown after measurement)
                if showConfirmButton, let height = arSession.measuredHeightCM {
                    Button {
                        store.update(heightInCM: height)
                        isPresented = false
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Label("Confirm Height", systemImage: "checkmark")
                            .font(.subheadline.bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.orange, in: Capsule())
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - Step Progress
    private var stepProgressView: some View {
        HStack(spacing: 8) {
            stepDot(label: "Bottom", isActive: true,
                    isCompleted: arSession.bottomAnchorPlaced)
            Rectangle()
                .fill(arSession.bottomAnchorPlaced ? Color.orange : Color.white.opacity(0.3))
                .frame(height: 2)
                .animation(.easeInOut, value: arSession.bottomAnchorPlaced)
            stepDot(label: "Top", isActive: arSession.bottomAnchorPlaced,
                    isCompleted: arSession.measuredHeightCM != nil)
            Rectangle()
                .fill(arSession.measuredHeightCM != nil ? Color.orange : Color.white.opacity(0.3))
                .frame(height: 2)
                .animation(.easeInOut, value: arSession.measuredHeightCM != nil)
            stepDot(label: "Done", isActive: arSession.measuredHeightCM != nil,
                    isCompleted: false)
        }
        .padding(.horizontal, 24)
    }

    private func stepDot(label: String, isActive: Bool, isCompleted: Bool) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isCompleted ? Color.orange : (isActive ? Color.white : Color.white.opacity(0.3)))
                .frame(width: 12, height: 12)
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            Text(label)
                .font(.caption2)
                .foregroundColor(isActive ? .white : .white.opacity(0.4))
        }
    }
}
