//
//  SetProfileViewModel.swift
//  TrekFit
//
//  ViewModel: SetProfileViewModel
//  Sits between SetProfileView and the UserProfile model.
//  Responsibilities:
//    1. Hold the draft profile the user is editing (reactive via @Published)
//    2. Validate the form before saving
//    3. Persist the profile to UserDefaults when the user taps "Set Profile"
//    4. Load any previously saved profile on launch
//

import Foundation
import Combine

// MARK: - SetProfileViewModel

/// ObservableObject so SwiftUI views can subscribe and re-render on changes.
final class SetProfileViewModel: ObservableObject {

    // MARK: - Published State

    /// The live draft of the profile being edited in the form.
    /// Every field change in the view updates this object.
    @Published var draft: UserProfile

    /// Controls whether a validation alert is shown (e.g. name is empty)
    @Published var showValidationAlert: Bool = false

    /// The message shown inside the validation alert
    @Published var validationMessage: String = ""

    // MARK: - Constants

    /// UserDefaults key used to store / retrieve the encoded UserProfile
    private let storageKey = "saved_user_profile"

    // MARK: - Init

    /// Initialises the ViewModel by loading any previously saved profile.
    /// Falls back to an empty profile if nothing has been saved yet.
    init() {
        self.draft = SetProfileViewModel.loadProfile(key: "saved_user_profile") ?? .empty
    }

    // MARK: - Computed Helpers

    /// Formatted date string shown in the Date of Birth row (e.g. "Jan 7, 2004")
    var formattedDateOfBirth: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium   // "Jan 7, 2004"
        formatter.timeStyle = .none
        return formatter.string(from: draft.dateOfBirth)
    }

    // MARK: - Public Actions

    /// Validates and saves the profile.
    /// - Returns: `true` if save succeeded, `false` if validation failed.
    @discardableResult
    func saveProfile() -> Bool {
        // --- Validation ---
        guard !draft.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Please enter your name before saving."
            showValidationAlert = true
            return false
        }
        
        // --- Validation: Weight ---
            guard draft.weight > 0 else {
                validationMessage = "Please enter your body weight before saving."
                showValidationAlert = true
                return false
            }

        // --- Persistence ---
        // Encode the Codable struct and write the raw Data to UserDefaults.
        // This is appropriate for a prototype; a production app would use a
        // proper data layer (e.g. SwiftData / Core Data).
        do {
            let encoded = try JSONEncoder().encode(draft)
            UserDefaults.standard.set(encoded, forKey: storageKey)
            return true
        } catch {
            validationMessage = "Failed to save profile. Please try again."
            showValidationAlert = true
            return false
        }
    }

    // MARK: - Private Helpers

    /// Attempts to decode a UserProfile from UserDefaults for the given key.
    /// Returns `nil` if no data exists or decoding fails.
    private static func loadProfile(key: String) -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
}
