import Foundation

// MARK: - Gender Enum
/// Represents the biological gender options available during profile setup.
enum Gender: String, CaseIterable, Codable, CustomStringConvertible {
    case male   = "Male"
    case female = "Female"

    var description: String { rawValue }
}

// MARK: - UserProfile
struct UserProfile: Codable {
    var name: String
    var dateOfBirth: Date
    var gender: Gender
    var weight: Double
    var boxHeight: Double
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    // MARK: - Default Value
    static var empty: UserProfile {
        UserProfile(
            name: "",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -22, to: Date()) ?? Date(),
            gender: .male,
            weight: 0.0,
            boxHeight: 0.20
        )
    }
}
