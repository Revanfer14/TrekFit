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
//    5. Update boxHeight from MeasureBoxView
//

import Foundation
import Combine

// MARK: - SetProfileViewModel

/// ObservableObject so SwiftUI views can subscribe and re-render on changes.
/// Shared across the app via @EnvironmentObject so MeasureBoxView can update boxHeight.
final class SetProfileViewModel: ObservableObject {
    // MARK: - Published State
    /// The live draft of the profile being edited in the form.
    @Published var draft: UserProfile

    @Published var showValidationAlert: Bool = false
    @Published var validationMessage: String = ""

    // MARK: - Constants
    /// UserDefaults key — diubah jadi static biar bisa diakses dari luar
    static let storageKey = "saved_user_profile"

    // MARK: - Init

    init() {
        self.draft = SetProfileViewModel.loadProfile() ?? .empty
    }

    // MARK: - Computed Helpers
    /// The currently saved profile (not draft). Useful for views that need the persisted data.
    var savedProfile: UserProfile {
        SetProfileViewModel.loadProfile() ?? .empty
    }

    var formattedDateOfBirth: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: draft.dateOfBirth)
    }

    var formattedWeight: String {
        let kg = Int(draft.weight)
        let grams = Int((draft.weight - Double(kg)) * 100)
        return String(format: "%d.%02d kg", kg, grams)
    }

    // MARK: - Public Actions

    @discardableResult
    func saveProfile() -> Bool {
        guard !draft.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Please enter your name before saving."
            showValidationAlert = true
            return false
        }

        guard draft.weight > 0 else {
            validationMessage = "Please enter your weight before saving."
            showValidationAlert = true
            return false
        }

        return persistProfile(draft)
    }

    /// - Parameter heightInMeters: Tinggi box dalam meter (e.g. 0.30 untuk 30 cm)
    func updateBoxHeight(_ heightInMeters: Double) {
        // Load profile yang sudah tersimpan (atau pakai draft kalau belum ada)
        var profileToUpdate = SetProfileViewModel.loadProfile() ?? draft

        // Update field boxHeight saja
        profileToUpdate.boxHeight = heightInMeters

        // Simpan ke UserDefaults
        if persistProfile(profileToUpdate) {
            // Sync draft juga biar form di SetProfileView tetap up-to-date
            draft.boxHeight = heightInMeters
        }
    }

    // MARK: - Private Helpers
    @discardableResult
    private func persistProfile(_ profile: UserProfile) -> Bool {
        do {
            let encoded = try JSONEncoder().encode(profile)
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
            return true
        } catch {
            validationMessage = "Failed to save profile. Please try again."
            showValidationAlert = true
            return false
        }
    }

    static func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
}
