//
//  ChesterTestViewModel.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 04/05/26.
//

//  Responsibilities:
//    1. Load user profile (maxHR, hrThreshold) from UserDefaults
//    2. Drive the stage timer (tick every 0.01s for smooth elapsed display)
//    3. Drive the beat timer (tick at BPM interval → toggles isDark for flash effect)
//    4. Auto-advance stages after 120 seconds
//    5. Stop the test when HR ≥ threshold, all stages complete, or user taps Stop
//    6. Expose all UI-facing state as @Published properties

import SwiftUI
import Foundation
import Combine

// MARK: - Stage Config

struct StageConfig {
    let number: Int     // 1-based
    let bpm: Int        // metronome BPM for this stage
}

// MARK: - ChesterTestViewModel

final class ChesterTestViewModel: ObservableObject {

    // MARK: - Stage Definitions

    let stages: [StageConfig] = [
        StageConfig(number: 1, bpm: 60),
        StageConfig(number: 2, bpm: 80),
        StageConfig(number: 3, bpm: 100),
        StageConfig(number: 4, bpm: 120),
        StageConfig(number: 5, bpm: 140),
    ]

    let stageDuration: TimeInterval = 120

    // MARK: - Dependencies

    private let hrMonitor: HeartRateMonitor
    private static let stageWorkloads: [Double] = [11, 14, 17, 20, 23]

    // MARK: - Published UI State

    /// Current stage index (0-based internally, displayed as 1-based)
    @Published var currentStageIndex: Int = 0
    
    /// Raw HR readings for the stage currently in progress
    @Published var currentStageReadings: [Double] = []

    /// Completed stage results accumulated during the test
    @Published var completedStages: [StageResult] = []

    /// Elapsed seconds within the current stage
    @Published var stageElapsed: TimeInterval = 0

    /// Toggles on every beat — drives light ↔ dark flash in the View
    @Published var isDark: Bool = false

    /// True once the test has ended for any reason — triggers navigation to Results
    @Published var testFinished: Bool = false

    /// Why the test stopped
    @Published var stopReason: TestEndReason = .completed

    /// User profile-derived values
    @Published var maxHR: Double = 195
    @Published var hrThreshold: Double = 156

    // MARK: - Timers

    private var stageTimer: Timer?
    private var beatTimer: Timer?

    // MARK: - Computed Properties

    var currentStage: StageConfig { stages[currentStageIndex] }

    var currentHR: Double { hrMonitor.currentHR ?? 0 }

    /// HR as a 0…1 fraction of maxHR — used for the orange progress bar
    var hrProgress: Double {
        guard maxHR > 0 else { return 0 }
        return min(currentHR / maxHR, 1.0)
    }

    /// Elapsed time formatted as MM:SS,ms
    var elapsedString: String {
        let totalSeconds = Int(stageElapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let ms = Int((stageElapsed - Double(totalSeconds)) * 100)
        return String(format: "%02d:%02d,%02d", minutes, seconds, ms)
    }

    // MARK: - Init

    init(hrMonitor: HeartRateMonitor) {
        self.hrMonitor = hrMonitor
    }

    // MARK: - Public API

    /// Call from View's onAppear
    func startTest() {
        loadProfile()
        startHRRecording()
        startStageTimer()
        startBeatTimer()
    }

    /// Call from View's onDisappear or when navigating away
    func stopAll() {
        stageTimer?.invalidate()
        stageTimer = nil
        beatTimer?.invalidate()
        beatTimer = nil
    }

    /// Called when user confirms Stop
    func manualStop() {
        stopReason = .manualStop
        stopAll()
        finalizeAndSave(reason: .manualStop)
        testFinished = true
    }

    // MARK: - Profile Loading

    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: "saved_user_profile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            maxHR = Double(220 - profile.age)
        }
        hrThreshold = maxHR * 0.8
    }

    // MARK: - Stage Timer

    private func startStageTimer() {
        stageTimer?.invalidate()
        stageTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }

            self.stageElapsed += 0.01

            // Check max HR threshold
            if self.currentHR >= self.hrThreshold {
                self.stopReason = .maxHRReached
                self.stopAll()
                self.finalizeAndSave(reason: .maxHRReached)
                self.testFinished = true
                return
            }

            // Auto-advance or complete
            if self.stageElapsed >= self.stageDuration {
                if self.currentStageIndex < self.stages.count - 1 {
                    self.advanceStage()
                } else {
                    self.stopReason = .completed
                    self.stopAll()
                    self.finalizeAndSave(reason: .completed)
                    self.testFinished = true
                }
            }
        }
    }
    
    // MARK: - HR Recording

    private func startHRRecording() {
        hrMonitor.onHeartRateUpdate = { [weak self] bpm in
            guard let self, !self.testFinished else { return }
            DispatchQueue.main.async {
                self.currentStageReadings.append(bpm)
            }
        }
    }

    private func advanceStage() {
        let result = StageResult(
            stageNumber: currentStage.number,
            duration: stageElapsed,
            heartRateReadings: currentStageReadings
        )
        completedStages.append(result)
        currentStageReadings = []

        currentStageIndex += 1
        stageElapsed = 0
        startBeatTimer()
    }

    // MARK: - Beat Timer

    private func startBeatTimer() {
        beatTimer?.invalidate()
        let interval = 60.0 / Double(currentStage.bpm)
        beatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.08)) {
                    self.isDark.toggle()
                }
            }
        }
    }
    
    // MARK: - Finalize

    private func finalizeAndSave(reason: TestEndReason) {
        // Simpan stage terakhir yang mungkin belum penuh
        let lastResult = StageResult(
            stageNumber: currentStage.number,
            duration: stageElapsed,
            heartRateReadings: currentStageReadings
        )
        completedStages.append(lastResult)

        // Bangun ChesterTest dari UserDefaults profile
        if let data = UserDefaults.standard.data(forKey: "saved_user_profile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {

            var test = ChesterTest(from: profile)
            test.stageResults = completedStages
            test.endReason = reason
            test.vo2max = calculateVO2Max()
            test.save()
        }
    }
    
    private func calculateVO2Max() -> Double {
        // Ambil stage yang punya HR readings
        let validStages = completedStages.filter { !$0.heartRateReadings.isEmpty }
        guard validStages.count >= 2 else { return 0 }

        // Pasangkan setiap stage dengan workload-nya berdasarkan nomor stage (1-based)
        let xs = validStages.map { Self.stageWorkloads[$0.stageNumber - 1] }  // workload
        let ys = validStages.map { $0.heartRateReadings.reduce(0, +) / Double($0.heartRateReadings.count) }  // avgHR
        let n  = Double(validStages.count)

        // Linear regression: HR = a + b × workload
        let sumX  = xs.reduce(0, +)
        let sumY  = ys.reduce(0, +)
        let sumXY = zip(xs, ys).map(*).reduce(0, +)
        let sumX2 = xs.map { $0 * $0 }.reduce(0, +)

        let b = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)  // kemiringan garis
        let a = (sumY - b * sumX) / n                                   // titik awal garis

        // maxHR = a + b × vo2max  →  vo2max = (maxHR - a) / b
        guard b > 0 else { return 0 }
        return max(0, (maxHR - a) / b)
    }
}
