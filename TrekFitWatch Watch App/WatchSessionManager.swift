//
//  WatchSessionManager.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 01/05/26.
//

import Foundation
import HealthKit
import WatchConnectivity
import Combine

class WatchSessionManager: NSObject, ObservableObject {
    
    private let healthStore = HKHealthStore()
    private var wcSession: WCSession?
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    // Timer untuk memaksa pengiriman per 1 detik
    private var heartRateTimer: Timer?
    
    @Published var currentHR: Double = 0
    @Published var isRunning: Bool = false
    @Published var isStarting: Bool = false
    
    override init() {
        super.init()
        setupWCSession()
    }
    
    // WatchConnectivity Setup
    
    private func setupWCSession() {
        guard WCSession.isSupported() else { return }
        wcSession = WCSession.default
        wcSession?.delegate = self
        wcSession?.activate()
    }
    
    // HealthKit Authorization
    
    func requestAuthorization() async {
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKQuantityType(.heartRate)]
        
        try? await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }
    
    // Start / Stop Workout Session
    
    func startWorkout() async {        
        await requestAuthorization()
        
        DispatchQueue.main.async  {
            self.isStarting = true
        }
        
        let config = HKWorkoutConfiguration()
        config.activityType = .other 
        config.locationType = .indoor
        
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            
            session.delegate = self
            builder.delegate = self
            
            self.workoutSession = session
            self.builder = builder
            
            session.startActivity(with: Date())
            try await builder.beginCollection(at: Date())
            
            DispatchQueue.main.async {
                self.isStarting = false
                self.isRunning = true
                self.startPushingDataEverySecond()
            }
        } catch {
            print("❌ Failed to start workout: \(error)")
        }
    }
    
    func stopWorkout() async {
        workoutSession?.end()
        try? await builder?.endCollection(at: Date())
        _ = try? await builder?.finishWorkout()
        
        DispatchQueue.main.async {
            self.isRunning = false
            self.stopPushingData()
            self.currentHR = 0
        }
    }
    
    // Kirim data per 1 detik supaya watch selalu detected ketika lagi aktif
    private func startPushingDataEverySecond() {
        heartRateTimer?.invalidate()
        
        // Timer berjalan di Main Thread setiap 1.0 detik
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            guard self.currentHR > 0 else { return }
            
            self.sendHRToiPhone(self.currentHR)
            print("⏱️ Timer Tick: \(self.currentHR) bpm → forced sent to iPhone")
        }
    }
    
    private func stopPushingData() {
        heartRateTimer?.invalidate()
        heartRateTimer = nil
    }
    
    
    private func sendHRToiPhone(_ bpm: Double) {
        guard let session = wcSession else { return }
            print("📡 isReachable: \(session.isReachable)")
            guard session.isReachable else {
                print("⚠️ iPhone tidak reachable")
                return
            }
        
        session.sendMessage(["hr": bpm], replyHandler: nil, errorHandler: { error in
            print("❌ WCSession error: \(error.localizedDescription)")
        })
    }
}


// Buat track state (Running, Stopped, Error) dari workout
extension WatchSessionManager: HKWorkoutSessionDelegate {
    func workoutSession(_ session: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        print("Workout state: \(fromState.rawValue) → \(toState.rawValue)")
    }
    
    func workoutSession(_ session: HKWorkoutSession, didFailWithError error: Error) {
        print("❌ Workout session error: \(error)")
    }
}

// Buat ambil data heart rate secara real time
extension WatchSessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
        guard let hrType = collectedTypes.first(where: {
            $0 == HKQuantityType(.heartRate)
        }) as? HKQuantityType else { return }
        
        guard let stats = workoutBuilder.statistics(for: hrType),
              let latestValue = stats.mostRecentQuantity() else { return }
        
        let bpm = latestValue.doubleValue(for: HKUnit(from: "count/min"))
        
        DispatchQueue.main.async {
            self.currentHR = bpm
            print("💓 Sensor Updated: \(bpm) bpm")
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}

// Handle connection dari watch ke iphone
extension WatchSessionManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("WCSession activated: \(activationState.rawValue)")
    }
}
