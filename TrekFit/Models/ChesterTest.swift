//
//  ChesterTest.swift
//  TrekFit
//
//  Model: ChesterTest & StageResult
//  Plain Codable structs stored in UserDefaults — no SwiftData needed.
//  For the Result page, only `vo2max: Double` is consumed.
//

import Foundation

// MARK: - StageResult

/// Heart rate and timing data for one stage of the Chester Step Test.
struct StageResult: Codable {
    var stageNumber: Int
    var averageHR: Double
    var lastHR: Double
    var duration: TimeInterval
}

// MARK: - ChesterTest

/// Represents a single Chester Step Test session.
/// Conforms to Codable so it can be saved/loaded from UserDefaults.
struct ChesterTest: Codable {
    var nama: String?
    var usia: Int
    var beratBadan: Double?
    var tanggal: Date
    var stageResults: [StageResult]

    /// Estimated VO2 Max (mL/kg/min) — the only value consumed by ResultView.
    var vo2max: Double

    init(usia: Int, tanggal: Date = .now) {
        self.usia = usia
        self.tanggal = tanggal
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
        var test = ChesterTest(usia: 21, tanggal: .now)
        test.nama = "Axel"
        test.beratBadan = 68.0
        test.vo2max = 38.4
        test.stageResults = [
            StageResult(stageNumber: 1, averageHR: 110, lastHR: 115, duration: 120),
            StageResult(stageNumber: 2, averageHR: 125, lastHR: 130, duration: 120),
            StageResult(stageNumber: 3, averageHR: 140, lastHR: 145, duration: 120)
        ]
        return test
    }
}
