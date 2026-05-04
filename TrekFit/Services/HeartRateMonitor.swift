//
//  HeartRateMonitor.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 01/05/26.
//

import Foundation
import HealthKit
import WatchConnectivity

@Observable
final class HeartRateMonitor: NSObject {
    
    var currentHR: Double? = nil
    var lastReadingDate: Date? = nil
    var isReceivingData: Bool = false
    
    var onHeartRateUpdate: ((Double) -> Void)?
    
    private var wcSession: WCSession?
    private var stalenessTimer: Timer?
    
    override init() {
        super.init()
        setupWCSession()
    }
    
    // MARK: - WatchConnectivity
    
    private func setupWCSession() {
        guard WCSession.isSupported() else { return }
        wcSession = WCSession.default
        wcSession?.delegate = self
        wcSession?.activate()
    }
    
    // MARK: - HealthKit Auth (tetap dibutuhkan untuk baca history)
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HRError.healthKitNotAvailable
        }
        let healthStore = HKHealthStore()
        let hrType = HKQuantityType(.heartRate)
        try await healthStore.requestAuthorization(toShare: [], read: [hrType])
    }
    
    // MARK: - Start / Stop
    
    func startMonitoring() {
        startStalenessCheck()
        print("📡 HR Monitor started — waiting for Watch data")
    }
    
    func stopMonitoring() {
        stalenessTimer?.invalidate()
        stalenessTimer = nil
        isReceivingData = false
    }
    
    // MARK: - Staleness Check
    
    private func startStalenessCheck() {
        stalenessTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if let lastDate = self.lastReadingDate {
                let staleness = Date().timeIntervalSince(lastDate)
                DispatchQueue.main.async {
                    self.isReceivingData = staleness < 4.0
                }
            } else {
                DispatchQueue.main.async {
                    self.isReceivingData = false
                }
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension HeartRateMonitor: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("📱 iPhone WCSession activated: \(activationState.rawValue)")
    }
    
    // Terima HR message dari Watch
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let bpm = message["hr"] as? Double else { return }
        
        print("💓 Received from Watch: \(bpm) bpm")
        
        DispatchQueue.main.async { [weak self] in
            self?.currentHR = bpm
            self?.lastReadingDate = Date()
            self?.isReceivingData = true
            self?.onHeartRateUpdate?(bpm)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

// MARK: - Errors

enum HRError: LocalizedError {
    case healthKitNotAvailable
    case authorizationDenied
    
    var errorDescription: String? {
        switch self {
        case .healthKitNotAvailable: return "HealthKit tidak tersedia di perangkat ini."
        case .authorizationDenied: return "Akses Heart Rate ditolak."
        }
    }
}
