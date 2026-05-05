//
//  CameraMeasurementSheet.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 05/05/26.
//

import SwiftUI

// MARK: - Measurement Range
enum MeasurementRange {
    static let min: Double = 20.0
    static let max: Double = 40.0

    static func isValid(_ value: Double) -> Bool {
        value >= min && value <= max
    }
}

// MARK: - Camera Measurement Sheet
struct CameraMeasurementSheet: View {
    @EnvironmentObject var store: MeasurementStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var arVM = ARMeasurementViewModel()

    // MARK: - UI States
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showSuccessPulse = false
    @State private var buttonScale: CGFloat = 1.0

    // MARK: - Computed
    private var formattedHeight: String {
        String(format: "%.1f", arVM.currentHeight)
    }

    private var actionTitle: String {
        switch arVM.points.count {
        case 0: return "Tap Floor Point"
        case 1: return "Tap Top of Box"
        default: return "Measure Again"
        }
    }

    private var actionIcon: String {
        switch arVM.points.count {
        case 0: return "dot.circle"
        case 1: return "arrow.up.circle"
        default: return "arrow.counterclockwise"
        }
    }

    private var isMeasurementValid: Bool {
        MeasurementRange.isValid(arVM.currentHeight)
    }

    var body: some View {
        ZStack {
            // AR camera background
            ARMeasurementView(viewModel: arVM)
                .ignoresSafeArea()

            // Dark vignette overlay for depth
            VignetteOverlay()

            // Main overlay content
            VStack(spacing: 0) {
                // MARK: Top Bar
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                Spacer()

                // MARK: Center Area - Crosshair + Height Display
                centerArea

                Spacer()

                // MARK: Bottom Controls
                bottomControls
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }

            // Success pulse animation overlay
            if showSuccessPulse {
                SuccessPulseView()
                    .allowsHitTesting(false)
            }
        }
        .presentationBackground(.clear)
        .alert("Invalid Measurement", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 12) {
            // Close button
            CircleButton(
                icon: "xmark",
                iconColor: .primary,
                bgColor: .clear
            ) {
                Haptics.impact(.light)
                dismiss()
            }

            Spacer()

            // Title pill
            HStack(spacing: 6) {
                Image(systemName: "camera.viewfinder")
                    .font(.subheadline)
                Text("AR Measure")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )

            Spacer()

            // Confirm button (only when measurement exists)
            if arVM.currentHeight > 0 {
                CircleButton(
                    icon: "checkmark",
                    iconColor: .white,
                    bgColor: isMeasurementValid ? .green : .orange
                ) {
                    confirmMeasurement()
                }
                .scaleEffect(buttonScale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonScale)
            } else {
                // Placeholder for alignment
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
        }
    }

    // MARK: - Center Area
    private var centerArea: some View {
        ZStack {
            // Crosshair with animated rings
            CrosshairView(
                isActive: arVM.points.count < 2,
                pointCount: arVM.points.count
            )

            // Height display card (floating above crosshair when measured)
            if arVM.currentHeight > 0 {
                VStack(spacing: 8) {
                    // Measurement card
                    MeasurementCard(
                        height: arVM.currentHeight,
                        isValid: isMeasurementValid,
                        unit: store.unit.symbol
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))

                    // Validation badge
                    if !isMeasurementValid {
                        ValidationBadge(
                            message: arVM.currentHeight < MeasurementRange.min
                                ? "Too low — minimum \(Int(MeasurementRange.min)) cm"
                                : "Too high — maximum \(Int(MeasurementRange.max)) cm"
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .offset(y: -120)
            }

            // Point indicators
            HStack(spacing: 16) {
                PointIndicator(
                    label: "Floor",
                    isSet: arVM.points.count >= 1,
                    number: 1
                )

                Rectangle()
                    .fill(arVM.points.count >= 2 ? .green : .white.opacity(0.3))
                    .frame(width: 24, height: 2)

                PointIndicator(
                    label: "Top",
                    isSet: arVM.points.count >= 2,
                    number: 2
                )
            }
            .offset(y: 100)
        }
    }

    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Instruction text
            if arVM.points.count < 2 {
                InstructionLabel(
                    text: arVM.points.count == 0
                        ? "Point camera at the floor and tap the button"
                        : "Move camera to the top of the box and tap",
                    icon: "hand.tap.fill"
                )
            }

            // Main action button
            ActionButton(
                title: actionTitle,
                icon: actionIcon,
                isActive: arVM.points.count < 2
            ) {
                Haptics.impact(.medium)
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    buttonScale = 0.95
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    buttonScale = 1.0
                }
                
                if arVM.points.count >= 2 {
                    Haptics.notify(.warning)
                    arVM.reset()
                } else {
                    arVM.addPoint()
                }
            }

            // Range hint
            HStack(spacing: 4) {
                Image(systemName: "ruler")
                    .font(.caption2)
                Text("Valid range: \(Int(MeasurementRange.min))-\(Int(MeasurementRange.max)) cm")
                    .font(.caption2)
            }
            .foregroundStyle(.white.opacity(0.6))
        }
    }

    // MARK: - Actions

    private func confirmMeasurement() {
        Haptics.impact(.light)

        if !isMeasurementValid {
            let isTooLow = arVM.currentHeight < MeasurementRange.min
            let range = "\(Int(MeasurementRange.min))-\(Int(MeasurementRange.max))"

            validationMessage = isTooLow
                ? "Your measurement (\(formattedHeight) cm) is below the recommended range of \(range) cm for a Chester Step Test. Please verify your box height."
                : "Your measurement (\(formattedHeight) cm) exceeds the recommended range of \(range) cm for a Chester Step Test. Please verify your box height."

            showValidationAlert = true
            return
        }

        saveAndDismiss()
    }

    private func saveAndDismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showSuccessPulse = true
        }

        Haptics.notify(.success)
        store.updateHeight(arVM.currentHeight)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            dismiss()
        }
    }
}

// MARK: - UI Components

struct CircleButton: View {
    let icon: String
    let iconColor: Color
    let bgColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(bgColor)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct VignetteOverlay: View {
    var body: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [.clear, .black.opacity(0.3)],
                center: .center,
                startRadius: geo.size.width * 0.3,
                endRadius: geo.size.width * 0.8
            )
            .allowsHitTesting(false)
        }
    }
}

struct CrosshairView: View {
    let isActive: Bool
    let pointCount: Int

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(isActive ? .white.opacity(0.3) : .green.opacity(0.5), lineWidth: 1)
                .frame(width: 80, height: 80)
                .scaleEffect(pulseScale)
                .animation(
                    isActive
                        ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
                        : .default,
                    value: pulseScale
                )
                .onAppear { pulseScale = isActive ? 1.15 : 1.0 }

            // Middle ring
            Circle()
                .stroke(isActive ? .white.opacity(0.5) : .green, lineWidth: 1.5)
                .frame(width: 50, height: 50)

            // Center cross
            Group {
                Rectangle()
                    .fill(isActive ? .white : .green)
                    .frame(width: 20, height: 2)
                Rectangle()
                    .fill(isActive ? .white : .green)
                    .frame(width: 2, height: 20)
            }

            // Corner brackets
            CrosshairBrackets(color: isActive ? .white.opacity(0.6) : .green.opacity(0.6))
        }
    }
}

struct CrosshairBrackets: View {
    let color: Color
    let size: CGFloat = 60
    let thickness: CGFloat = 2
    let length: CGFloat = 12

    var body: some View {
        ZStack {
            // Top-left
            VStack(spacing: 0) {
                Rectangle().fill(color).frame(width: length, height: thickness)
                Rectangle().fill(color).frame(width: thickness, height: length)
            }
            .position(x: -size/2, y: -size/2)

            // Top-right
            VStack(spacing: 0) {
                Rectangle().fill(color).frame(width: length, height: thickness)
                Rectangle().fill(color).frame(width: thickness, height: length)
            }
            .rotationEffect(.degrees(90))
            .position(x: size/2, y: -size/2)

            // Bottom-left
            VStack(spacing: 0) {
                Rectangle().fill(color).frame(width: length, height: thickness)
                Rectangle().fill(color).frame(width: thickness, height: length)
            }
            .rotationEffect(.degrees(-90))
            .position(x: -size/2, y: size/2)

            // Bottom-right
            VStack(spacing: 0) {
                Rectangle().fill(color).frame(width: length, height: thickness)
                Rectangle().fill(color).frame(width: thickness, height: length)
            }
            .rotationEffect(.degrees(180))
            .position(x: size/2, y: size/2)
        }
        .frame(width: size, height: size)
    }
}

struct MeasurementCard: View {
    let height: Double
    let isValid: Bool
    let unit: String

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isValid ? .green.opacity(0.2) : .orange.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(isValid ? .green : .orange)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Measured Height")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", height))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(unit)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isValid ? .green.opacity(0.3) : .orange.opacity(0.3), lineWidth: 1)
                )
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ValidationBadge: View {
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
            Text(message)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(.orange)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.black.opacity(0.7))
                .overlay(
                    Capsule()
                        .stroke(.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PointIndicator: View {
    let label: String
    let isSet: Bool
    let number: Int

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isSet ? .green : .white.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(isSet ? .green.opacity(0.5) : .white.opacity(0.3), lineWidth: 1)
                    )

                if isSet {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(isSet ? .green : .white.opacity(0.5))
        }
    }
}

struct InstructionLabel: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.black.opacity(0.5))
        )
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                Text(title)
                    .font(.headline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isActive
                                    ? [Color.orange, Color.orange.opacity(0.8)]
                                    : [.gray.opacity(0.6), .gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Capsule()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
            )
            .shadow(
                color: isActive ? .orange.opacity(0.4) : .clear,
                radius: isPressed ? 4 : 12,
                x: 0,
                y: isPressed ? 2 : 6
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.2)) { isPressed = false }
        }
    }
}

struct SuccessPulseView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0

    var body: some View {
        Circle()
            .fill(.green)
            .frame(width: 200, height: 200)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    scale = 3.0
                    opacity = 0.0
                }
            }
    }
}

// MARK: - Button Press Modifier
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

#Preview {
    CameraMeasurementSheet()
        .environmentObject(MeasurementStore())
}
