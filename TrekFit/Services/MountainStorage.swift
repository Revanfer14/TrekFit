//
//  MountainStorage.swift
//  TrekFit
//
//  Service: MountainStorage
//  Persists the user's selected mountain ID to UserDefaults.
//
//  Why this exists:
//  The navigation flow has a gap between SelectMountainView and ResultView —
//  the entire Chester test flow (ConnectWatch → Guide → Countdown → Test) runs
//  in between. We can't pass the Mountain object through all those screens easily,
//  so we persist just the mountain ID here and look it up again in ResultView.
//
//  Usage:
//    MountainStorage.save(mountain)      // called in SelectMountainView on Select/Skip
//    MountainStorage.load()              // called in ResultView to reconstruct TestResult
//

import Foundation

// MARK: - MountainStorage

enum MountainStorage {

    private static let key = "selected_mountain_id"

    /// Saves the selected mountain's UUID string to UserDefaults.
    /// Pass `nil` when the user taps Skip (no mountain selected).
    static func save(_ mountain: Mountain?) {
        if let mountain = mountain {
            UserDefaults.standard.set(mountain.id.uuidString, forKey: key)
        } else {
            // Explicitly remove so ResultView knows the user skipped
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    /// Loads the previously saved mountain from the sample data list by matching UUID.
    /// Returns `nil` if the user skipped or no mountain was saved.
    static func load() -> Mountain? {
        guard let savedID = UserDefaults.standard.string(forKey: key) else { return nil }
        return Mountain.sampleMountains.first { $0.id.uuidString == savedID }
    }
}
