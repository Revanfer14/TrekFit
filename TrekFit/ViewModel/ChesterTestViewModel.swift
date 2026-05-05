//
//  ChesterTestViewModel.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 04/05/26.
//

import SwiftUI
import Foundation
import Combine

struct TestStage: Identifiable {
    let id: Int
    let number: Int
    let workload: Double
    let bpm: Int
    var hrReadings: [Double] = []
    var duration: TimeInterval = 0

    var avgHR: Double {
        guard !hrReadings.isEmpty else { return 0 }
        return hrReadings.reduce(0, +) / Double(hrReadings.count)
    }

    var lastHR: Double {
        hrReadings.last ?? 0
    }
}


final class ChesterTestViewModel: ObservableObject {

    @Published var stages: [TestStage]
    @Published var currentStageIndex: Int = 0
    @Published var currentHR: Double = 0
    @Published var elapsedString: String = "0:00"
    @Published var testFinished: Bool = false
    @Published var stopReason: TestEndReason? = nil
    @Published var vo2max: Double = 0

    @Published var isDark: Bool = false

    private static let stageDuration: TimeInterval = 120
    private static let hrThresholdRatio: Double = 0.80

    private let userAge: Int
    private let userWeight: Double
    private let userBoxHeight: Double
    let maxHR: Double
    let hrThreshold: Double

    private let hrMonitor: HeartRateMonitor

    private var stageTimer: Timer?
    private var elapsedTimer: Timer?
    private var stageElapsed: TimeInterval = 0
    private var totalElapsed: TimeInterval = 0
    private var beatTimer: Timer?

    private var recentHRReadings: [Double] = []
    private static let movingAvgWindow = 3


    init(hrMonitor: HeartRateMonitor) {
        self.hrMonitor = hrMonitor

        let profile = ChesterTestViewModel.loadProfile()
        self.userAge    = profile?.age    ?? 25
        self.userWeight = profile?.weight ?? 70.0
        self.userBoxHeight  = profile?.boxHeight ?? 0.20

        self.maxHR      = Double(220 - (profile?.age ?? 25))
        self.hrThreshold = maxHR * ChesterTestViewModel.hrThresholdRatio
        
        let cyclesPerMin: [Double] = [15, 20, 25, 30, 35]
        
        let stepH  = profile?.boxHeight ?? 0.20
        
        self.stages = cyclesPerMin.enumerated().map { idx, cycles in
            let bpm = cycles * 4 // Ini untuk suara metronom (60, 80, 100, dst)
            let stepsPerMin = cycles // Ini untuk rumus beban kerja (15, 20, 25, 30, 35)
            
            let workload = (0.2 * stepsPerMin) + (1.33 * 1.8 * stepH * stepsPerMin) + 3.5
            return TestStage(id: idx, number: idx + 1, workload: workload, bpm: Int(bpm))
        }
    }

    var currentStage: TestStage { stages[currentStageIndex] }

    var hrProgress: Double {
        min(currentHR / hrThreshold, 1.0)
    }
    
    // Buat start chester step test

    func startTest() {
        hrMonitor.onHeartRateUpdate = { [weak self] bpm in
            self?.handleHRUpdate(bpm)
        }
        startStageTimer()
        startElapsedTimer()
        startBeatTimer()
    }

    // Buat stop semua proses
    
    func stopAll() {
        stageTimer?.invalidate()
        elapsedTimer?.invalidate()
        beatTimer?.invalidate()
        hrMonitor.onHeartRateUpdate = nil
    }
    
    // Buat manual stop button

    func manualStop() {
        finishTest(reason: .manualStop)
    }

    
    // Func ini dipanggil setiap nerima HR baru dari Watch
    
    private func handleHRUpdate(_ rawBPM: Double) {
        recentHRReadings.append(rawBPM)
        
        // Max 3  di array (buat ngurangin noise / data error) -> [102,103,104] in 101 -> [103,104,101]
        
        if recentHRReadings.count > Self.movingAvgWindow {
            recentHRReadings.removeFirst()
        }
        let smoothed = recentHRReadings.reduce(0, +) / Double(recentHRReadings.count)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentHR = smoothed
            
            // Record into current stage
            self.stages[self.currentStageIndex].hrReadings.append(smoothed)

            if smoothed >= self.hrThreshold {
                self.finishTest(reason: .maxHRReached)
            }
        }
    }

    // Buat durasi timer ketika cst, make sure 2 minutes per stage
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
    
    // Buat next stage
    private func advanceStage() {
        stageTimer?.invalidate()

        let nextIndex = currentStageIndex + 1

        if nextIndex >= stages.count {
            finishTest(reason: .completed)
        } else {
            currentStageIndex = nextIndex
            stageElapsed = 0
            recentHRReadings.removeAll()
            startStageTimer()
            startBeatTimer()
        }
    }

    //  Total timer di cst
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
    
    // Timer buat beat sfx
    private func startBeatTimer() {
        beatTimer?.invalidate()
        
        let interval = 60.0 / Double(currentStage.bpm)
        
        beatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.08)) {
                    playSound("BeepSound")
                    self.isDark.toggle()
                }
            }
        }
    }

    // Func untuk finish cst
    private func finishTest(reason: TestEndReason) {
        guard !testFinished else { return }

        stopReason = reason

        stages[currentStageIndex].duration = stageElapsed

        stopAll()
        
        vo2max = calculateVO2Max()
        
        saveTestToUserDefaults()

        testFinished = true
    }

    // Buat itung VO2Max dari cst, rumusnya based on:
    // Reference: Sykes, K. & Roberts, A. (2004). Physiotherapy, 90(4), 183–188.
    private func calculateVO2Max() -> Double {
        let completedStages = stages.filter { !$0.hrReadings.isEmpty }
        
        print("=== VO2MAX CALCULATION DEBUG ===")
        print("👤 Age: \(userAge), Weight: \(userWeight)kg, BoxHeight: \(userBoxHeight)m")
        print("❤️ MaxHR: \(maxHR), HRThreshold: \(hrThreshold)")
        print("📊 Completed stages: \(completedStages.count)")
        
        for stage in completedStages {
            print("--- Stage \(stage.number) ---")
            print("   Workload: \(stage.workload)")
            print("   BPM setting: \(stage.bpm)")
            print("   HR Readings (\(stage.hrReadings.count)): \(stage.hrReadings)")
            print("   Avg HR: \(stage.avgHR)")
        }
        
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


        guard b > 0 else { return 0 }
        
        let result = max(0, (maxHR - a) / b)
        print("Result VO2Max: \(result) ml/kg/min")
        return result
    }

    // Func buat ambil profile user saat ini
    private static func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: "saved_user_profile") else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    // Buat save cst ke UserDefaults
    private func saveTestToUserDefaults() {
        guard let profile = Self.loadProfile() else { return }
        
        var test = ChesterTest(from: profile)
        
        test.stageResults = stages
            .filter {!$0.hrReadings.isEmpty}
            .map { stage in
            StageResult(
                stageNumber: stage.number,
                duration: stage.duration,
                heartRateReadings: stage.hrReadings
            )
        }
        
        test.vo2max = self.vo2max
        test.endReason = self.stopReason ?? .completed
        
        test.save()
    }
}
