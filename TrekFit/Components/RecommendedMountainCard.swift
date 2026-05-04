//
//  RecommendedMountainCard.swift
//  TrekFit
//
//  Component: RecommendedMountainCard
//  Displays a mountain card with photo, name, summit height, and
//  a "Min. VO₂ max : X ml/kg/min" orange pill badge.
//  Used in ResultView for both the recommended mountain section
//  and as the comparison card when a mountain is selected.
//
//  Reuses the same image/asset naming as MountainCardView (Mountain1, Mountain2, Mountain3).
//

import SwiftUI

// MARK: - RecommendedMountainCard

struct RecommendedMountainCard: View {

    // MARK: - Inputs

    /// The mountain to display
    let mountain: Mountain

    // MARK: - Constants

    private let photoHeight: CGFloat = 180

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Mountain Photo ────────────────────────────────────────────
            Image(mountain.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: photoHeight)
                .clipped()

            // ── Info Row ──────────────────────────────────────────────────
            HStack(alignment: .center) {

                // Left: icon + name + height
                VStack(alignment: .leading, spacing: 2) {

                    // Mountain icon + name
                    HStack(spacing: 4) {
                        Image("mountainIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)

                        Text(mountain.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }

                    // Summit height
                    Text(formattedHeight)
                        .font(.caption)
                        .foregroundColor(Color(.systemGray))
                }

                Spacer()

                // Right: Minimum VO2 Max badge (orange pill)
                VStack(spacing: 2) {
                    Text("Min. VO₂ max :")
                        .font(.caption2)
                        .foregroundColor(.white)

                    Text("\(formattedMinVO2) ml/kg/min")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("AccentOrange"))
                .clipShape(Capsule())
            }
            .padding(14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "E6E6E6"), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    /// Formatted summit height (e.g. "2,962 m")
    private var formattedHeight: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: mountain.summitHeight)) ?? "\(mountain.summitHeight)"
        return "\(formatted) m"
    }

    /// Formatted minimum VO2 Max (e.g. "35.0")
    private var formattedMinVO2: String {
        String(format: "%.1f", mountain.minimumVO2Max)
    }
}

// MARK: - Preview

#Preview {
    RecommendedMountainCard(mountain: Mountain.sampleMountains[0])
        .padding()
}
