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

// MARK: - UserDefaults Persistence (Latest Test)

extension ChesterTest {
    
    private static let storageKey = "saved_chester_test"
    private static let historyKey = "chester_test_history"
    
    /// Saves this test as the latest result (single record)
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: ChesterTest.storageKey)
        }
    }
    
    /// Loads the last saved test, or nil if none exists
    static func load() -> ChesterTest? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(ChesterTest.self, from: data)
    }
    
    /// Saves this test to the history array (newest first)
    func saveToHistory() {
        var history = ChesterTest.loadHistory()
        history.insert(self, at: 0)
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: ChesterTest.historyKey)
        }
    }
    
    /// Loads all saved history records
    static func loadHistory() -> [ChesterTest] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([ChesterTest].self, from: data)
        else { return [] }
        return history
    }
}

// MARK: - Dummy Data

extension ChesterTest {
    
    static var dummy: ChesterTest {
        var test = ChesterTest(from: .empty, testDate: .now)
        test.name = "Axel"
        test.age = 21
        test.gender = Gender.male.rawValue
        test.vo2max = 30.0
        test.stageResults = [
            StageResult(stageNumber: 1, duration: 120, heartRateReadings: [105, 108, 112, 115]),
            StageResult(stageNumber: 2, duration: 120, heartRateReadings: [120, 125, 128, 130]),
            StageResult(stageNumber: 3, duration: 120, heartRateReadings: [138, 141, 143, 145])
        ]
        test.endReason = .completed
        return test
    }
}

// MARK: - Debug Helpers

extension ChesterTest {
    
    static func injectDummyHistory() {
        
        let existingHistory = ChesterTest.loadHistory()
        
        // 2. Jika history masih kosong, baru kita suntik data dummy
        guard existingHistory.isEmpty else {
            print("⏭️ History sudah ada isinya, suntikan dummy dibatalkan.")
            return
        }
        
        let cal = Calendar.current
        let today = Date()
        
        func daysAgo(_ n: Int) -> Date {
            cal.date(byAdding: .day, value: -n, to: today) ?? today
        }
        
        var history: [ChesterTest] = []
        
        var t1 = ChesterTest.dummy
        t1.testDate = today
        t1.vo2max = 38.4
        t1.name = "Revan"
        history.append(t1)
        
        var t2 = ChesterTest.dummy
        t2.testDate = daysAgo(1)
        t2.vo2max = 37.1
        history.append(t2)
        
        var t3 = ChesterTest.dummy
        t3.testDate = daysAgo(3)
        t3.vo2max = 36.8
        history.append(t3)
        
        var t4 = ChesterTest.dummy
        t4.testDate = daysAgo(8)
        t4.vo2max = 35.5
        history.append(t4)
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "chester_test_history")
            print("✅ Dummy history injected: \(history.count) records")
        }
    }
}
