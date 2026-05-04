//
//  UserProfile.swift
//  TrekFit
//
//  Model: UserProfile
//  Represents the user's personal profile data used throughout the app.
//  Age is computed automatically from dateOfBirth so it never goes stale.
//  Data is persisted in UserDefaults (lightweight, suitable for a first prototype).
//

import Foundation

// MARK: - Gender Enum

/// Represents the biological gender options available during profile setup.
/// `CustomStringConvertible` lets us display a human-readable label directly in the UI.
enum Gender: String, CaseIterable, Codable, CustomStringConvertible {
    case male   = "Male"
    case female = "Female"

    /// The label shown in the UI (e.g. picker, row value)
    var description: String { rawValue }
}

// MARK: - UserProfile

/// The core data model for a TrekFit user.
/// Conforms to `Codable` so it can be easily encoded/decoded for UserDefaults persistence.
struct UserProfile: Codable {

    // MARK: Stored Properties

    /// The user's display name (e.g. "Jeson")
    var name: String

    /// The user's date of birth — age is derived from this value
    var dateOfBirth: Date

    /// The user's gender selection
    var gender: Gender

    // MARK: Computed Properties

    /// Calculates the user's current age in whole years from `dateOfBirth` to today.
    /// This is computed on the fly so it always reflects the current date.
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    // MARK: - Codable Support for Gender

    // Because `Gender` is a `String` enum it is already `Codable` — no extra work needed.

    // MARK: - Default Value

    /// A blank profile used to pre-populate the form before the user fills it in.
    static var empty: UserProfile {
        UserProfile(
            name: "",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -22, to: Date()) ?? Date(),
            gender: .male
        )
    }
}
