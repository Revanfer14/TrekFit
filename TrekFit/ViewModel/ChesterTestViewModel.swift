//
//  ChesterTestViewModel.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 04/05/26.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Stage Model

struct TestStage: Identifiable {
    let id: Int
    let number: Int                  // 1–5 (display label)
    let workload: Double             // ml/kg/min, pre-defined per protocol (20cm step)
    let bpm: Int
    var hrReadings: [Double] = []    // all HR values collected during this stage
    var duration: TimeInterval = 0   // actual duration (≤120s)

    var avgHR: Double {
        guard !hrReadings.isEmpty else { return 0 }
        return hrReadings.reduce(0, +) / Double(hrReadings.count)
    }

    var lastHR: Double {
        hrReadings.last ?? 0
    }
}

// MARK: - ChesterTestViewModel

final class ChesterTestViewModel: ObservableObject {

    @Published var stages: [TestStage]
    @Published var currentStageIndex: Int = 0
    @Published var currentHR: Double = 0
    @Published var elapsedString: String = "0:00"
    @Published var testFinished: Bool = false
    @Published var stopReason: TestEndReason? = nil
    @Published var vo2max: Double = 0

    // MARK: - Dark mode toggle (background flips on beat)
    @Published var isDark: Bool = false

    // MARK: - Constants

    /// Workload (ml/kg/min) per stage for a 20cm step, per Sykes protocol
    private static let stageWorkloads: [Double] = [11, 14, 17, 20, 23]

    /// Duration of each stage in seconds
    private static let stageDuration: TimeInterval = 10

    /// Stop threshold — 80% of max HR
    private static let hrThresholdRatio: Double = 0.80

    // MARK: - Profile Data

    private let userAge: Int
    private let userWeight: Double
    let maxHR: Double
    let hrThreshold: Double          // 80% of maxHR

    // MARK: - HR Monitor

    private let hrMonitor: HeartRateMonitor

    // MARK: - Timers

    private var stageTimer: Timer?
    private var elapsedTimer: Timer?
    private var stageElapsed: TimeInterval = 0
    private var totalElapsed: TimeInterval = 0
    private var beatTimer: Timer?

    // MARK: - Moving Average (noise smoothing, window = 3)

    private var recentHRReadings: [Double] = []
    private static let movingAvgWindow = 3

    // MARK: - Init

    init(hrMonitor: HeartRateMonitor) {
        self.hrMonitor = hrMonitor

        // Load saved profile
        let profile = ChesterTestViewModel.loadProfile()
        self.userAge    = profile?.age    ?? 25
        self.userWeight = profile?.weight ?? 70.0

        // Derived HR values
        self.maxHR      = Double(220 - (profile?.age ?? 25))
        self.hrThreshold = maxHR * ChesterTestViewModel.hrThresholdRatio
        
        let stageData: [(workload: Double, bpm: Int)] = [
                (11, 60), (14, 80), (17, 100), (20, 120), (23, 140)
            ]
        
        // Build 5 stages
        self.stages = stageData.enumerated().map { idx, data in
                TestStage(id: idx, number: idx + 1, workload: data.workload, bpm: data.bpm) // <-- Masukkan data.bpm
            }
    }

    // MARK: - Computed Helpers

    var currentStage: TestStage { stages[currentStageIndex] }

    /// HR as a fraction of maxHR (0.0 – 1.0), clamped for the progress bar
    var hrProgress: Double {
        min(currentHR / maxHR, 1.0)
    }

    // MARK: - Public API

    func startTest() {
        hrMonitor.onHeartRateUpdate = { [weak self] bpm in
            self?.handleHRUpdate(bpm)
        }
        startStageTimer()
        startElapsedTimer()
        startBeatTimer()
    }

    func stopAll() {
        stageTimer?.invalidate()
        elapsedTimer?.invalidate()
        beatTimer?.invalidate()
        hrMonitor.onHeartRateUpdate = nil
    }

    func manualStop() {
        finishTest(reason: .manualStop)
    }

    // MARK: - HR Handling

    private func handleHRUpdate(_ rawBPM: Double) {
        // --- Moving average (smooth noise) ---
        recentHRReadings.append(rawBPM)
        if recentHRReadings.count > Self.movingAvgWindow {
            recentHRReadings.removeFirst()
        }
        let smoothed = recentHRReadings.reduce(0, +) / Double(recentHRReadings.count)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentHR = smoothed

            // Record into current stage
            self.stages[self.currentStageIndex].hrReadings.append(smoothed)

            // Check stop condition (use smoothed value)
            if smoothed >= self.hrThreshold {
                self.finishTest(reason: .maxHRReached)
            }
        }
    }

    // MARK: - Stage Timer

    private func startStageTimer() {
        stageElapsed = 0
        stageTimer?.invalidate()

        stageTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.stageElapsed += 1
            self.stages[self.currentStageIndex].duration = self.stageElapsed

            if self.stageElapsed >= Self.stageDuration {
                self.advanceStage()
            }
        }
    }

    private func advanceStage() {
        stageTimer?.invalidate()

        let nextIndex = currentStageIndex + 1

        if nextIndex >= stages.count {
            // All 5 stages done
            finishTest(reason: .completed)
        } else {
            currentStageIndex = nextIndex
            stageElapsed = 0
            recentHRReadings.removeAll()
            startStageTimer()
            startBeatTimer()
        }
    }

    // MARK: - Elapsed Timer (total test clock)

    private func startElapsedTimer() {
        totalElapsed = 0
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.totalElapsed += 1
            let minutes = Int(self.totalElapsed) / 60
            let seconds = Int(self.totalElapsed) % 60
            self.elapsedString = String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func startBeatTimer() {
        beatTimer?.invalidate()
        
        // Hitung interval waktu antar ketukan berdasarkan BPM saat ini
        // Rumus: 60 detik dibagi BPM
        let interval = 60.0 / Double(currentStage.bpm)
        
        beatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.08)) {
                    playSound("BeepSound") //
                    self.isDark.toggle()
                }
            }
        }
    }

    // MARK: - Finish Test

    private func finishTest(reason: TestEndReason) {
        guard !testFinished else { return }
        stopAll()
        stopReason = reason

        stages[currentStageIndex].duration = stageElapsed

        vo2max = calculateVO2Max()
        
        saveTestToUserDefaults()

        testFinished = true
    }

    // MARK: - VO2Max Calculation (Linear Extrapolation, Sykes method)
    //
    // Algorithm:
    //   1. Collect (workload, avgHR) pairs from completed stages
    //   2. Fit a linear regression: HR = a + b * workload
    //   3. Extrapolate to maxHR → find the workload at maxHR
    //   4. That workload IS the predicted VO2Max
    //
    // Reference: Sykes, K. & Roberts, A. (2004). Physiotherapy, 90(4), 183–188.

    private func calculateVO2Max() -> Double {
        let completedStages = stages.filter { !$0.hrReadings.isEmpty }
        guard completedStages.count >= 2 else { return 0 }

        // Kumpulkan pasangan (workload, avgHR) dari setiap stage
        let xs = completedStages.map { $0.workload }  // x = workload
        let ys = completedStages.map { $0.avgHR }     // y = heart rate
        let n  = Double(completedStages.count)

        // Hitung slope (b) dan intercept (a) dari garis lurus: HR = a + b × workload
        let sumX  = xs.reduce(0, +)
        let sumY  = ys.reduce(0, +)
        let sumXY = zip(xs, ys).map(*).reduce(0, +)
        let sumX2 = xs.map { $0 * $0 }.reduce(0, +)

        let b = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)  // kemiringan garis
        let a = (sumY - b * sumX) / n                                   // titik awal garis

        // Balik rumusnya: kita tahu maxHR, cari workload-nya
        // maxHR = a + b × vo2max  →  vo2max = (maxHR - a) / b
        guard b > 0 else { return 0 }
        return max(0, (maxHR - a) / b)
    }

    // MARK: - Persistence Helper

    private static func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: "saved_user_profile") else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    private func saveTestToUserDefaults() {
        guard let profile = Self.loadProfile() else { return }
        
        // 1. Buat kerangka test baru dari profil
        var test = ChesterTest(from: profile)
        
        // 2. Petakan array 'TestStage' (UI Model) menjadi 'StageResult' (Data Model)
        test.stageResults = stages.map { stage in
            StageResult(
                stageNumber: stage.number,
                duration: stage.duration,
                heartRateReadings: stage.hrReadings
            )
        }
        
        // 3. Masukkan hasil akhirnya
        test.vo2max = self.vo2max
        test.endReason = self.stopReason ?? .completed
        
        // 4. Panggil method save() bawaan dari struct ChesterTest
        test.save()
    }
}
