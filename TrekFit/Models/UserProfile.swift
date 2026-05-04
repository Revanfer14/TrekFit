//
//  UserProfile.swift
//  TrekFit
//

import Foundation

enum Gender: String, CaseIterable, Codable, CustomStringConvertible {
    case male   = "Male"
    case female = "Female"

    var description: String { rawValue }
}

struct UserProfile: Codable {

    var name: String
    var dateOfBirth: Date
    var gender: Gender
    var weight: Double
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    static var empty: UserProfile {
        UserProfile(
            name: "",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -22, to: Date()) ?? Date(),
            gender: .male,
            weight: 0.0
        )
    }
}
