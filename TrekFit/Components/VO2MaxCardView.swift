//
//  VO2MaxCardView.swift
//  TrekFit
//
//  Component: VO2MaxCardView
//  A colored stat card displaying a VO2 Max value with label and unit.
//
//  Layout (per design spec):
//    ┌─────────────────────────────┐
//    │ [icon]                      │
//    │ Label text                  │
//    │                             │
//    │                    38.4     │
//    │               ml/kg/min     │
//    └─────────────────────────────┘
//
//  - Icon alone on top-left
//  - Label below the icon, left-aligned
//  - Value + unit pushed to bottom-right
//
//  Color rules:
//    .orange → user's own VO2 Max card (#FF8D28), uses vo2icon.png asset
//    .green  → mountain card when user passes (#34C759), uses mountain.2.fill SF symbol
//    .red    → mountain card when user fails  (#FF383C), uses mountain.2.fill SF symbol
//

import SwiftUI

// MARK: - VO2MaxCardView

struct VO2MaxCardView: View {

    // MARK: - Card Style

    enum CardStyle {
        case orange
        case green
        case red

        var backgroundColor: Color {
            switch self {
            case .orange: return Color("AccentOrange")
            case .green:  return Color(hex: "34C759")
            case .red:    return Color(hex: "FF383C")
            }
        }
    }

    // MARK: - Inputs

    let style: CardStyle

    /// Label shown below the icon (e.g. "Your VO₂ max", "Est. Min. for Mt. Rinjani")
    let label: String

    /// The formatted VO2 Max value (e.g. "38.4")
    let value: String

    /// Full width when used solo (no mountain selected), half width when paired
    var isFullWidth: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Top section: icon + label ─────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {

                // Icon — vo2icon.png for orange, SF symbol for green/red
                Group {
                    if style == .orange {
                        // Custom image asset: add vo2icon.png to Assets.xcassets as "vo2icon"
                        Image("vo2icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    } else {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }

                // Label below icon, left-aligned, wraps to 2 lines if needed
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // ── Bottom section: value + unit, right-aligned ───────────────
            HStack {
                Spacer()

                VStack(alignment: .trailing, spacing: 0) {

                    // Large VO2 Max number
                    Text(value)
                        .font(.system(size: isFullWidth ? 52 : 38, weight: .bold))
                        .foregroundColor(.white)

                    // Unit on its own line, right-aligned below the number
                    Text("ml/kg/min")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .frame(height: 160)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        // Solo full-width (no mountain selected)
        VO2MaxCardView(style: .orange, label: "Your VO₂ max", value: "38.4", isFullWidth: true)

        // Paired (mountain selected)
        HStack(spacing: 12) {
            VO2MaxCardView(style: .orange, label: "Your VO₂ max", value: "38.4")
            VO2MaxCardView(style: .red, label: "Est. Min. for Mt. Rinjani", value: "45.0")
        }
        HStack(spacing: 12) {
            VO2MaxCardView(style: .orange, label: "Your VO₂ max", value: "38.4")
            VO2MaxCardView(style: .green, label: "Est. Min. for Mt. Gede", value: "35.0")
        }
    }
    .padding()
}
