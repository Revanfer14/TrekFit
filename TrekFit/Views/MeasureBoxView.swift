//
//  MeasureBoxView.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 04/05/26.
//

import SwiftUI

struct MeasureBoxView: View {
    @ObservedObject var store: MeasurementStore
    @Environment(\.dismiss) private var dismiss

    @State private var showCameraSheet = false
    @State private var inputText: String = ""
    @State private var animateValue = false

    var body: some View {
        VStack {
            // MARK: Custom Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                Spacer()
                Text("Measure Box")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: Title Section
                        titleSection

                        // MARK: Camera Card
                        cameraCard

                        // MARK: Manual Entry
                        manualEntrySection

                        // MARK: Helper Info
                        helperInfoCard

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .background(Color(.systemBackground))
                .navigationBarHidden(true)
                .overlay(alignment: .bottom) {
                    confirmButton
                }
            }
            .sheet(isPresented: $showCameraSheet) {
                CameraBottomSheet(store: store, isPresented: $showCameraSheet)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                syncInputText()
            }
            .onChange(of: store.stepHeight) { _ in
                syncInputText()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    animateValue = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animateValue = false
                }
            }
            .onChange(of: store.unit) { _ in
                syncInputText()
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Sync input text
    private func syncInputText() {
        let val = store.displayValue
        inputText = val.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(val))
            : String(format: "%.1f", val)
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Step Height")
                .font(.largeTitle.bold())

            Text("Find an elevated area or box near you to be used for a step test.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }

    // MARK: - Camera Card
    private var cameraCard: some View {
        Button {
            showCameraSheet = true
        } label: {
            HStack(spacing: 16) {
                // Camera icon background
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Measure with Camera")
                        .font(.title3.bold())
                        .foregroundColor(.primary)

                    Text("Point your camera at the step to auto-detect its height")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Manual Entry Section
    private var manualEntrySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manual Entry")
                .font(.title3.bold())

            VStack(spacing: 16) {
                // Number input display
                HStack(alignment: .lastTextBaseline) {
                    TextField("", text: $inputText)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .scaleEffect(animateValue ? 1.08 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: animateValue)
                        .onChange(of: inputText) { newVal in
                            if let val = Double(newVal) {
                                store.updateFromDisplay(val)
                            }
                        }

                    Text(store.unit.symbol)
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottom) {
                    Divider()
                        .background(Color(.separator))
                        .padding(.horizontal, 24)
                        .offset(y: 4)
                }
                .padding(.top, 8)
                .padding(.bottom, 8)

                // Preset pills
                HStack(spacing: 10) {
                    ForEach(store.presets, id: \.self) { preset in
                        presetPill(value: preset)
                    }
                }
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: Preset Pill
    private func presetPill(value: Double) -> some View {
        let isSelected = abs(store.stepHeight - value) < 0.5
        let displayVal = MeasurementUnit.centimeter.convert(value, to: store.unit)
        let label = displayVal.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(displayVal))
            : String(format: "%.1f", displayVal)

        return Button {
            store.update(heightInCM: value)
        } label: {
            Text(label)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.orange : Color(.secondarySystemGroupedBackground),
                            in: Capsule())
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }

    // MARK: - Helper Info Card
    private var helperInfoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.primary)
                .font(.body)
                .padding(.top, 1)

            Text("Chester Step Test are typically using a **30 cm** elevated step.")
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: Confirm Button
    private var confirmButton: some View {
        Button {
            store.confirm()
        } label: {
            Text("Confirm Step Height")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(store.isConfirmed ? Color.green : Color.orange,
                            in: Capsule())
                .overlay {
                    if store.isConfirmed {
                        HStack {
                            Image(systemName: "checkmark")
                                .fontWeight(.bold)
                            Text("Confirmed!")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: store.isConfirmed)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .background(Color.white.ignoresSafeArea()) 
    }
}

// MARK: - Preview
#Preview {
    MeasureBoxView(store: MeasurementStore.shared)
}
