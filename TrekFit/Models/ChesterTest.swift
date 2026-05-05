//
//  ChesterTest.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 04/05/26.
//

import Foundation

struct StageResult: Codable {
    var stageNumber: Int
    var duration: TimeInterval
    var heartRateReadings: [Double]
    
    var averageHeartRate: Double {
        guard !heartRateReadings.isEmpty else { return 0 }
        return heartRateReadings.reduce(0, +) / Double(heartRateReadings.count)
    }
        
    var lastHeartRate: Double {
        heartRateReadings.last ?? 0
    }
}

enum TestEndReason: String, Codable {
    case completed
    case maxHRReached
    case manualStop
}

struct ChesterTest: Codable {

    var name: String
    var age: Int
    var gender: String
    var testDate: Date
    var stageResults: [StageResult]
    var vo2max: Double
    var maxHr: Double
    var targetHr: Double
    var endReason: TestEndReason
    

    init(from profile: UserProfile, testDate: Date = .now) {
        self.name = profile.name
        self.age = profile.age
        self.gender = profile.gender.rawValue
        self.testDate = testDate
        self.stageResults = []
        self.vo2max = 0
        self.maxHr = 220 - Double(profile.age)
        self.targetHr = maxHr * 0.80
        self.endReason = .completed
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
            StageResult(stageNumber: 1, duration: 120, heartRateReadings: [105, 108, 112, 115]),
            StageResult(stageNumber: 2, duration: 120, heartRateReadings: [120, 125, 128, 130]),
            StageResult(stageNumber: 3, duration: 120, heartRateReadings: [138, 141, 143, 145])
        ]
        test.endReason = .completed
        return test
    }
}
