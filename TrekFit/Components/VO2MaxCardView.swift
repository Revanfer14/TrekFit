//
//  VO2MaxCardView.swift
//  TrekFit
//
//  Component: VO2MaxCardView
//  A colored stat card displaying a VO2 Max value with a label and unit.
//  Used in pairs (user vs mountain) or solo (no mountain selected).
//
//  Color rules (per design spec):
//    - .orange  → always used for the user's own VO2 Max card (#FF8D28)
//    - .green   → mountain card when user VO2 Max ≥ mountain minimum (#34C759)
//    - .red     → mountain card when user VO2 Max < mountain minimum (#FF383C)
//

import SwiftUI

// MARK: - VO2MaxCardView

struct VO2MaxCardView: View {

    // MARK: - Card Style Enum

    /// Controls the background color of the card
    enum CardStyle {
        case orange   // user's VO2 Max — always orange
        case green    // mountain comparison — user passes
        case red      // mountain comparison — user fails

        /// The background color for this card style
        var backgroundColor: Color {
            switch self {
            case .orange: return Color("AccentOrange")          // #FF8D28
            case .green:  return Color(hex: "34C759")           // iOS system green
            case .red:    return Color(hex: "FF383C")           // accent red
            }
        }

        /// SF Symbol name shown at the top-left of the card
        var iconName: String {
            switch self {
            case .orange: return "figure.walk"
            case .green:  return "mountain.2.fill"
            case .red:    return "mountain.2.fill"
            }
        }
    }

    // MARK: - Inputs

    /// Visual style (orange / green / red)
    let style: CardStyle

    /// The label shown above the number (e.g. "Your VO₂ max")
    let label: String

    /// The VO2 Max value string (e.g. "38.4")
    let value: String

    /// Whether this card takes full width (solo) or half width (paired)
    var isFullWidth: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // --- Icon + label row ---
            HStack(spacing: 6) {
                Image(systemName: style.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // --- VO2 Max number + unit ---
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: isFullWidth ? 52 : 40, weight: .bold))
                    .foregroundColor(.white)

                Text("ml/kg/min")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.bottom, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .frame(height: 150)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    HStack {
        VO2MaxCardView(style: .orange, label: "Your VO₂ max", value: "38.4")
        VO2MaxCardView(style: .red,    label: "Est. Minimum for Mt. Semeru", value: "45.0")
    }
    .padding()
}
