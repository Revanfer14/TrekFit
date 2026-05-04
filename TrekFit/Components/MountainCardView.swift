//
//  MountainCardView.swift
//  TrekFit
//
//  Component: MountainCardView + MountainInfoSection
//
//  MountainCardView — full card with photo + info + Select button.
//  Used in SelectMountainView and the "Compare another mountain" picker sheet.
//
//  MountainInfoSection — reusable bottom info block (name, height, description).
//  Used by both MountainCardView (with Select button) and MountainDetailCard in ResultView
//  (without Select button), ensuring pixel-perfect consistency between the two screens.
//
//  Layout:
//    ┌──────────────────────────────┐
//    │  Mountain photo              │
//    ├──────────────────────────────┤
//    │  [⛰] Name        [Select]  │  ← Select only in MountainCardView
//    │      X,XXXm                  │
//    │  Short description (≤3 lines)│
//    └──────────────────────────────┘
//

import SwiftUI

// MARK: - MountainInfoSection

/// The bottom info block shared by MountainCardView and MountainDetailCard.
/// Accepts an optional trailing view (Select button or Min VO2 badge) so callers
/// control what appears on the right side of the name row.
struct MountainInfoSection<TrailingView: View>: View {

    let mountain: Mountain

    /// Optional trailing view in the name row (e.g. Select button, Min VO2 badge, or EmptyView)
    @ViewBuilder let trailingView: () -> TrailingView

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // --- Name row + optional trailing view ---
            HStack(alignment: .center) {
                Text(mountain.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                trailingView()
            }

            // --- Mountain icon + summit height (same line, matching prototype) ---
            HStack(spacing: 4) {
                Image("mountainIcon")
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
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
    }

    // MARK: - Helpers

    private var formattedHeight: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: mountain.summitHeight)) ?? "\(mountain.summitHeight)"
        return "\(formatted)m"
    }
}

// MARK: - MountainCardView

/// Full mountain card with photo + MountainInfoSection + Select button.
/// Used in SelectMountainView and the picker sheet in ResultView.
struct MountainCardView: View {

    let mountain: Mountain
    let onSelect: () -> Void

    private let photoHeight: CGFloat = 200

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Mountain Photo ────────────────────────────────────────────
            Image(mountain.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: photoHeight)
                .clipped()

            // ── Info Section with Select button ───────────────────────────
            MountainInfoSection(mountain: mountain) {
                Button(action: onSelect) {
                    Text("Select")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .background(Color("AccentOrange"))
                .clipShape(Capsule())
                .buttonStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "E6E6E6"), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    MountainCardView(mountain: Mountain.sampleMountains[0]) {}
        .padding()
}
