//  Sits between SetProfileView and the UserProfile model.

import Foundation
import Combine

// MARK: - SetProfileViewModel
final class SetProfileViewModel: ObservableObject {
    @Published var draft: UserProfile
    @Published var showValidationAlert: Bool = false
    @Published var validationMessage: String = ""

    // MARK: - Constants
    /// UserDefaults key — diubah jadi static biar bisa diakses dari luar
    static let storageKey = "saved_user_profile"

    init() {
        self.draft = SetProfileViewModel.loadProfile() ?? .empty
    }

    // Helpers
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
    // Sekarang validasi cuman ada di bagian name dan weight
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
