//
//  AudioService.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 04/05/26.
//


import SwiftUI
import AVFoundation
import Combine

class AudioService: ObservableObject {
    static let shared = AudioService()

    var sfxPlayer: [String: AVAudioPlayer] = [:]
    
    private init() {} // Mencegah inisialisasi ganda
    
    // MARK: - Sound Effects (SFX)
    func playSFX(filename: String, ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("File SFX tidak ditemukan: \(filename).\(ext)")
            return
        }
        
        do {
            // Set kategori ke ambient agar tidak mematikan musik dari aplikasi lain (opsional tapi disarankan)
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let player = try AVAudioPlayer(contentsOf: url)
            // Simpan player ke dictionary agar tidak langsung terhapus dari memori sebelum bunyinya selesai
            sfxPlayer[filename] = player
            player.play()
        } catch {
            print("Error memutar SFX: \(error.localizedDescription)")
        }
    }
}

// MARK: - Global Helper Functions

// Biar tinggal panggil playSound()
func playSound(_ file: String) {
    AudioService.shared.playSFX(filename: file)
}

// Fungsi Global untuk Getaran Maksimal
func playHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy, intensity: CGFloat = 1.0) {
    let generator = UIImpactFeedbackGenerator(style: style)
    
    generator.prepare()
    generator.impactOccurred(intensity: intensity)
}

// Fungsi Global untuk Haptic Notifikasi (Success/Error)
func playNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(type)
}
