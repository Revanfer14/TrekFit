//
//  HeartRateMonitor.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 01/05/26.
//

import Foundation
import HealthKit
import WatchConnectivity
import Combine

final class HeartRateMonitor: NSObject, ObservableObject {
    
    @Published var currentHR: Double? = nil
    @Published var lastReadingDate: Date? = nil
    @Published var isReceivingData: Bool = false
    
    var onHeartRateUpdate: ((Double) -> Void)?
    
    private var wcSession: WCSession?
    private var stalenessTimer: Timer?
    
    // Singleton - dipanggil sekali doang buat initialize object
    
    override init() {
        super.init()
        print("HeartRateMonitor init called")
        setupWCSession()
        print("📱 HeartRateMonitor instance created: \(ObjectIdentifier(self))")
    }
    
    // Setup buat iphone ke apple watch pake WatchConnectivity supaya ip bisa dapet HR dari watch
    
    private func setupWCSession() {
        guard WCSession.isSupported() else {
                print("❌ WCSession not supported")
                return
            }
        wcSession = WCSession.default
        wcSession?.delegate = self
        wcSession?.activate()
        print("📱 WCSession setup, state: \(WCSession.default.activationState.rawValue)")
    }
    
    // Buat request access (ke Health) supaya bisa dapet real time HR
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HRError.healthKitNotAvailable
        }
        let healthStore = HKHealthStore()
        let hrType = HKQuantityType(.heartRate)
        try await healthStore.requestAuthorization(toShare: [], read: [hrType])
    }
    
    // Buat start dan stop monitoring real time HR
    
    func startMonitoring() {
        startStalenessCheck()
        print("📡 HR Monitor started — waiting for Watch data")
    }
    
    func stopMonitoring() {
        stalenessTimer?.invalidate()
        stalenessTimer = nil
        isReceivingData = false
    }
    
    // Buat selalu ngecek apakah ada data HR masuk atau ga (detect watch)
    
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

// Split responsibility -> Hal2 berkaitan dengan watch disini

extension HeartRateMonitor: WCSessionDelegate {
    
    // Flag buat ngasih tau Ip ke Watch udah connected or fail
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("📱 iPhone WCSession activated: \(activationState.rawValue), error: \(String(describing: error))")
    }
    
    // Dapetin data real time HR dari Watch -> setiap watch kirim HR, function ini jalan
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let bpm = message["hr"] as? Double else { return }
        
        print("💓 Received from Watch on instance: \(ObjectIdentifier(self))")
        print("💓 Received from Watch: \(bpm) bpm")
        
        DispatchQueue.main.async { [weak self] in
            self?.currentHR = bpm
            self?.lastReadingDate = Date()
            self?.isReceivingData = true
            self?.onHeartRateUpdate?(bpm)
        }
    }
    
    // Buat flag kalo session lama bakal diganti (tapi in this case gak perlu, karena ga gonta ganti watch) kalo diapus error :D
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    // Buat activate session baru, kalau session lama mati
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

// Label buat error message

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
