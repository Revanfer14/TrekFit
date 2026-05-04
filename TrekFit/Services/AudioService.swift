//
//  AudioService.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 04/05/26.
//

import AVFoundation
import UIKit

// MARK: - Sound Effect Enum

/// Semua sound effects yang dipakai di app.
/// Tambah case baru di sini jika butuh sound baru.
enum SoundEffect: String {
    // Chester Test
    case stageStart     = "stage_start"       // tiap stage baru dimulai
    case stageComplete  = "stage_complete"     // tiap stage selesai
    case testComplete   = "test_complete"      // tes selesai normal (5 stage)
    case maxHRReached   = "max_hr_reached"     // HR mencapai 80% max HR
    case countdown      = "countdown_beep"     // tiap detik di countdown 3-2-1
    case countdownGo    = "countdown_go"       // bunyi "go" saat tes mulai
    case heartbeat      = "heartbeat"          // opsional, notif HR update
    case buttonTap      = "button_tap"         // haptic-style tap sound
    case warning        = "warning"            // warning (HR gap / watch lepas)
}

// MARK: - Background Music Enum

/// Semua background music / ambient sound.
enum BackgroundMusic: String {
    case backgroundAmbient  = "bg_ambient"      // musik santai di home/guide
    case testInProgress     = "bg_test_music"   // musik saat tes berlangsung
}

// MARK: - AudioService

final class AudioService {

    // MARK: - Singleton

    static let shared = AudioService()
    private init() {
        configureAudioSession()
    }

    // MARK: - Private Players

    /// Player khusus background music (looping)
    private var musicPlayer: AVAudioPlayer?

    /// Pool of players untuk sound effects (support overlap/simultan)
    private var sfxPlayers: [AVAudioPlayer] = []

    /// Volume global untuk SFX (0.0 – 1.0)
    var sfxVolume: Float = 1.0

    /// Volume global untuk music (0.0 – 1.0)
    var musicVolume: Float = 0.4 {
        didSet { musicPlayer?.volume = musicVolume }
    }

    /// Apakah semua audio di-mute (misal user matikan sound di settings)
    var isMuted: Bool = false

    // MARK: - Audio Session Setup

    /// Mengkonfigurasi AVAudioSession agar musik bisa mix dengan audio lain
    /// (misal: Apple Watch notifications tetap bisa bunyi)
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ AudioService: Failed to configure audio session — \(error)")
        }
    }

    // MARK: - Sound Effects

    /// Play sebuah sound effect.
    /// - Parameters:
    ///   - sound: Enum `SoundEffect` yang ingin diputar
    ///   - volume: Override volume untuk sound ini (default: pakai `sfxVolume`)
    func playSound(_ sound: SoundEffect, volume: Float? = nil) {
        guard !isMuted else { return }

        // Cari file: coba .mp3 dulu, fallback ke .wav, .caf, .m4a
        let extensions = ["mp3", "wav", "caf", "m4a"]
        guard let url = findAudioFile(name: sound.rawValue, extensions: extensions) else {
            print("⚠️ AudioService: File '\(sound.rawValue)' tidak ditemukan di bundle.")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume ?? sfxVolume
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()

            // Simpan referensi agar tidak di-deallocate sebelum selesai
            sfxPlayers.append(player)

            // Bersihkan players yang sudah selesai (garbage collection ringan)
            sfxPlayers = sfxPlayers.filter { $0.isPlaying }
        } catch {
            print("⚠️ AudioService: Gagal play '\(sound.rawValue)' — \(error)")
        }
    }

    // MARK: - Background Music

    /// Putar background music. Otomatis loop.
    /// Jika music yang sama sudah berjalan, tidak akan restart.
    func playMusic(_ music: BackgroundMusic, fadeIn: Bool = true) {
        guard !isMuted else { return }

        let extensions = ["mp3", "wav", "caf", "m4a"]
        guard let url = findAudioFile(name: music.rawValue, extensions: extensions) else {
            print("⚠️ AudioService: Music file '\(music.rawValue)' tidak ditemukan.")
            return
        }

        // Hindari restart kalau sudah main lagu yang sama
        if let current = musicPlayer, current.isPlaying,
           current.url == url { return }

        do {
            musicPlayer?.stop()
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1           // loop selamanya
            player.volume = fadeIn ? 0 : musicVolume
            player.prepareToPlay()
            player.play()
            musicPlayer = player

            if fadeIn { fadeMusic(to: musicVolume, duration: 1.5) }
        } catch {
            print("⚠️ AudioService: Gagal play music '\(music.rawValue)' — \(error)")
        }
    }

    /// Stop background music dengan opsional fade out.
    func stopMusic(fadeOut: Bool = true) {
        guard let player = musicPlayer, player.isPlaying else { return }

        if fadeOut {
            fadeMusic(to: 0.0, duration: 1.0) {
                self.musicPlayer?.stop()
                self.musicPlayer = nil
            }
        } else {
            player.stop()
            musicPlayer = nil
        }
    }

    /// Pause background music (bisa di-resume).
    func pauseMusic() { musicPlayer?.pause() }

    /// Resume background music setelah di-pause.
    func resumeMusic() {
        guard !isMuted else { return }
        musicPlayer?.play()
    }

    // MARK: - Metronome Beep (khusus Chester Test)

    /// Play beep metronome berdasarkan step rate Chester Test.
    /// - Parameter bpm: Step rate (steps per minute) stage saat ini
    func startMetronome(bpm: Double) {
        stopMetronome()
        let interval = 60.0 / bpm
        metronomeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playSound(.countdown, volume: 0.7)
        }
    }

    func stopMetronome() {
        metronomeTimer?.invalidate()
        metronomeTimer = nil
    }

    private var metronomeTimer: Timer?

    // MARK: - Mute Toggle

    /// Toggle mute semua audio (SFX + music)
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            musicPlayer?.volume = 0
        } else {
            musicPlayer?.volume = musicVolume
        }
    }

    // MARK: - Private Helpers

    /// Cari file audio di bundle dengan fallback ke beberapa ekstensi.
    private func findAudioFile(name: String, extensions: [String]) -> URL? {
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }

    /// Fade volume music secara gradual menggunakan Timer.
    private func fadeMusic(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let player = musicPlayer else { return }

        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeDelta = (targetVolume - player.volume) / Float(steps)
        var currentStep = 0

        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            player.volume += volumeDelta

            if currentStep >= steps {
                player.volume = targetVolume
                timer.invalidate()
                completion?()
            }
        }
    }
}
