//
//  MountainCardView.swift
//  TrekFit
//
//  Component: MountainCardView
//  A self-contained card that displays a single mountain's photo, name,
//  summit height, short description, and a "Select" button.
//
//  Layout (top → bottom inside the card):
//    ┌──────────────────────────────┐
//    │  Mountain photo (fixed height)│
//    ├──────────────────────────────┤
//    │  Name              [Select]  │
//    │  ⛰ X,XXXm                   │
//    │  Short description (≤3 lines)│
//    └──────────────────────────────┘
//
//  Usage:
//    MountainCardView(mountain: mountain) {
//        // handle selection
//    }
//

import SwiftUI

// MARK: - MountainCardView

struct MountainCardView: View {

    // MARK: - Inputs

    /// The mountain data to display on this card
    let mountain: Mountain

    /// Called when the user taps the "Select" button on this card
    let onSelect: () -> Void

    // MARK: - Constants

    /// Fixed height of the mountain photo area at the top of the card
    private let photoHeight: CGFloat = 200

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Mountain Photo ────────────────────────────────────────────
            // Loads from Assets.xcassets using the imageName key (e.g. "Mountain1").
            // Falls back to a gray placeholder if the asset is missing.
            Image(mountain.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: photoHeight)
                .clipped()                          // prevent image bleeding outside card bounds

            // ── Info Section ──────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {

                // --- Name row + Select button ---
                HStack(alignment: .center) {

                    // Mountain name — bold headline
                    Text(mountain.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()

                    // Select button — orange pill, same brand style as PrimaryButtonView
                    // but compact (fixed width) for use inside a card
                    Button(action: onSelect) {
                        Text("Select")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    .background(Color("AccentOrange"))  // #FF8D28
                    .clipShape(Capsule())
                    .buttonStyle(.plain)
                }

                // --- Summit height row ---
                // Uses a custom mountain icon from Assets.xcassets + formatted elevation
                HStack(spacing: 4) {
                    Image("mountainIcon")               // mountainIcon.jpg in Assets.xcassets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)

                    Text(formattedHeight)
                        .font(.caption)
                        .foregroundColor(Color(.systemGray))
                }

                // --- Short description (max 3 lines) ---
                Text(mountain.shortDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)                       // cap at 3 lines as per the design spec
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        // Card container styling
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            // Subtle border matching the card edge
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "E6E6E6"), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    /// Formats the summit height with a thousands separator and "m" suffix.
    /// e.g. 3726 → "3,676m"
    private var formattedHeight: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: mountain.summitHeight)) ?? "\(mountain.summitHeight)"
        return "\(formatted)m"
    }
}

// MARK: - Preview

#Preview {
    MountainCardView(mountain: Mountain.sampleMountains[0]) {}
        .padding()
}
