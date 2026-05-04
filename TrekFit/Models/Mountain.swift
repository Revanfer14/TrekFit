//
//  Mountain.swift
//  TrekFit
//
//  Model: Mountain
//  Represents a single trekking mountain destination shown in the Select Mountain screen.
//
//  Properties:
//    - id             → Unique identifier (UUID), required by Identifiable for use in ForEach loops
//    - name           → Display name of the mountain (e.g. "Mount Gede")
//    - summitHeight   → Summit elevation in metres (e.g. 2958)
//    - shortDescription → 1–3 sentence overview shown on the card
//    - imageName      → Asset catalog key for the mountain's photo (e.g. "Mountain1")
//    - minimumVO2Max  → The minimum VO2 Max score required to safely climb this mountain.
//                       Used later in the fitness test result comparison screen.
//

import Foundation

// MARK: - Mountain

/// Data model for a trekking destination.
/// Conforms to `Identifiable` so SwiftUI `ForEach` can iterate without an explicit `id:` parameter.
struct Mountain: Identifiable {

    // MARK: - Properties

    /// Auto-generated unique ID — no manual management needed
    let id: UUID = UUID()

    /// Full display name of the mountain (e.g. "Mount Gede")
    let name: String

    /// Elevation of the summit in metres (e.g. 2958)
    let summitHeight: Int

    /// A short 1–3 sentence description shown beneath the mountain name on each card
    let shortDescription: String

    /// The key used to look up the mountain image in Assets.xcassets (e.g. "Mountain1")
    let imageName: String

    /// Minimum estimated VO2 Max (mL/kg/min) required to attempt this mountain.
    /// Referenced during the Chester Step Test result evaluation.
    let minimumVO2Max: Double
}

// MARK: - Sample Data

extension Mountain {

    /// Three pre-loaded mountains used for the prototype.
    /// Replace or extend this array when connecting to a real data source.
    static let sampleMountains: [Mountain] = [

        Mountain(
            name: "Mount Gede",
            summitHeight: 2_958,
            shortDescription: "An accessible stratovolcano featuring rainforest trails and stunning crater views",
            imageName: "Mountain1",
            minimumVO2Max: 35.0
        ),

        Mountain(
            name: "Mount Rinjani",
            summitHeight: 3_726,
            shortDescription: "A challenging trek rewarding climbers with a breathtaking caldera lake",
            imageName: "Mountain2",
            minimumVO2Max: 45.0
        ),

        Mountain(
            name: "Mount Merbabu",
            summitHeight: 3_145,
            shortDescription: "A moderate climb famous for its wide savannas and panoramic views",
            imageName: "Mountain3",
            minimumVO2Max: 38.0
        )
    ]
}
