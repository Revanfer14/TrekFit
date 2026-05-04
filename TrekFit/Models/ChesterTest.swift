//
//  ChesterTest.swift
//  TrekFit
//
//  Model: ChesterTest & StageResult
//  Plain Codable structs stored in UserDefaults — no SwiftData needed.
//  For the Result page, only `vo2max: Double` is consumed.
//
//  User profile fields (name, age, gender) are pulled directly from UserProfile
//  and stored here so the test session is self-contained for logging purposes.
//

import Foundation

// MARK: - StageResult

/// Heart rate and timing data collected during one stage of the Chester Step Test.
struct StageResult: Codable {
    var stageNumber: Int
    var averageHeartRate: Double     // renamed from averageHR
    var lastHeartRate: Double        // renamed from lastHR
    var duration: TimeInterval
}

// MARK: - ChesterTest

/// Represents a single Chester Step Test session performed by the user.
/// User profile data (name, age, gender) is copied in at test creation time
/// so the log is self-contained even if the profile changes later.
struct ChesterTest: Codable {

    // MARK: - User Profile Fields (from UserProfile)

    /// User's display name — copied from UserProfile.name
    var name: String

    /// User's age at the time of the test — copied from UserProfile.age
    var age: Int

    /// User's gender — copied from UserProfile.gender (stored as raw String for Codable)
    var gender: String

    // MARK: - Test Session Fields

    /// Date and time the test was conducted
    var testDate: Date                // renamed from tanggal

    /// Individual stage results collected during the test
    var stageResults: [StageResult]

    /// Estimated VO2 Max (mL/kg/min) calculated after the test completes.
    /// This is the primary value consumed by ResultView for comparison.
    var vo2max: Double

    // MARK: - Init

    /// Creates a new test session by pulling identity fields from a UserProfile.
    /// This way ChesterTest is always in sync with the profile at the time of testing.
    init(from profile: UserProfile, testDate: Date = .now) {
        self.name = profile.name
        self.age = profile.age
        self.gender = profile.gender.rawValue
        self.testDate = testDate
        self.stageResults = []
        self.vo2max = 0
    }
}

// MARK: - UserDefaults Persistence

extension ChesterTest {

    private static let storageKey = "saved_chester_test"

    /// Saves this test result to UserDefaults.
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: ChesterTest.storageKey)
        }
    }

    /// Loads the last saved test from UserDefaults, or returns nil if none exists.
    static func load() -> ChesterTest? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(ChesterTest.self, from: data)
    }
}

// MARK: - Dummy Data

extension ChesterTest {

    /// Pre-filled dummy used for previews and prototype navigation.
    /// vo2max 38.4 sits between Gede (35.0) and Rinjani (45.0) to demo both pass/fail states.
    static var dummy: ChesterTest {
        // Build from a dummy profile so the init stays consistent
        var test = ChesterTest(from: .empty, testDate: .now)
        test.name = "Axel"
        test.age = 21
        test.gender = Gender.male.rawValue
        test.vo2max = 38.4
        test.stageResults = [
            StageResult(stageNumber: 1, averageHeartRate: 110, lastHeartRate: 115, duration: 120),
            StageResult(stageNumber: 2, averageHeartRate: 125, lastHeartRate: 130, duration: 120),
            StageResult(stageNumber: 3, averageHeartRate: 140, lastHeartRate: 145, duration: 120)
        ]
        return test
    }
}
