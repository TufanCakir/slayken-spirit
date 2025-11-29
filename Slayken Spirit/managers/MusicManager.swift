//
//  MusicManager.swift
//  Slayken Fighter of Fists
//
//  Created by Tufan Cakir on 2025-10-30.
//

import AVFoundation
internal import Combine
import Foundation

@MainActor
final class MusicManager: NSObject, ObservableObject, AVAudioPlayerDelegate {

    // MARK: - Published
    @Published var isMusicOn: Bool {
        didSet { Task { await handleMusicToggle() } }
    }

    // MARK: - Private
    private(set) var player: AVAudioPlayer?
    private var fadeTask: Task<Void, Never>?
    private(set) var songs: [Song] = []

    private var currentIndex = 0

    // MARK: - INIT
    override init() {
        self.isMusicOn = UserDefaults.standard.bool(forKey: "isMusicOn")
        super.init()

        configureAudioSession()
        loadSongs()

        // Auto-Resume falls Musik aktiviert war
        if isMusicOn {
            Task { await playSong(at: currentIndex, fadeIn: true) }
        }
    }
}


// MARK: - PUBLIC API
extension MusicManager {

    /// Erzwungenen Song spielen (ignoriert "player läuft bereits")
    func forcePlaySong(index: Int) async {
        guard index >= 0, index < songs.count else {
            print("⚠️ Ungültiger Song-Index:", index)
            return
        }

        stopImmediately()
        currentIndex = index
        await playSong(at: index, fadeIn: true)
    }

    /// Normal Song spielen (ohne Stop, verhindert Doppelstart)
    func playSong(at index: Int, fadeIn: Bool) async {
        guard isMusicOn else { return }
        guard !songs.isEmpty else { return }

        if let p = player, p.isPlaying {
            print("⚠️ Player läuft bereits — kein Doppelstart.")
            return
        }

        guard index >= 0, index < songs.count else { return }

        currentIndex = index
        let song = songs[index]

        guard let url = Bundle.main.url(forResource: song.fileName, withExtension: "mp3") else {
            print("❌ MP3-Datei fehlt:", song.fileName)
            return
        }

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.volume = fadeIn ? 0.0 : 0.6
            newPlayer.numberOfLoops = 0
            newPlayer.prepareToPlay()
            newPlayer.play()

            player = newPlayer

            if fadeIn { await fadeInMusic(to: 0.6) }

            print("🎶 Now Playing:", song.title)

        } catch {
            print("❌ Fehler beim Abspielen:", error.localizedDescription)
            await skipToNextSong()
        }
    }

    /// Musik an/aus logik
    func toggleMusic() {
        isMusicOn.toggle()
    }
}

extension MusicManager {
    func stopMusic() async {
        player?.stop()
        player = nil
    }
}


// MARK: - PRIVATE HELPERS
extension MusicManager {

    private func stopImmediately() {
        fadeTask?.cancel()
        player?.stop()
        player = nil
    }

    private func handleMusicToggle() async {
        UserDefaults.standard.set(isMusicOn, forKey: "isMusicOn")

        if isMusicOn {
            print("🎵 Musik aktiviert")
            await playSong(at: currentIndex, fadeIn: true)
        } else {
            print("🔇 Musik deaktiviert")
            await fadeOutAndStop()
        }
    }
}


// MARK: - JSON LOADING
extension MusicManager {

    private func loadSongs() {
        guard let url = Bundle.main.url(forResource: "songs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(SongList.self, from: data)
        else {
            print("❌ songs.json NICHT gefunden oder fehlerhaft.")
            return
        }

        self.songs = decoded.songs

        if songs.isEmpty {
            print("❌ Keine Songs in JSON gefunden.")
        } else {
            print("🎵 \(songs.count) Songs geladen.")
        }
    }
}


// MARK: - AUDIO SESSION
extension MusicManager {

    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            // playback = ignoriert Stumm-Schalter
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ AudioSession konnte nicht gesetzt werden:", error.localizedDescription)
        }
    }
}


// MARK: - FADE LOGIC
extension MusicManager {

    private func fadeOutAndStop() async {
        guard let player = player else { return }

        fadeTask?.cancel()

        fadeTask = Task {
            let startVolume = player.volume
            let steps: Float = 25

            for i in stride(from: 0, through: steps, by: 1) {
                guard !Task.isCancelled else { return }

                let newVolume = startVolume * (1 - Float(i) / steps)
                player.volume = max(newVolume, 0)
                try? await Task.sleep(nanoseconds: 30_000_000)
            }

            stopImmediately()
            print("🛑 Musik gestoppt")
        }

        await fadeTask?.value
    }

    private func fadeInMusic(to target: Float) async {
        guard let player = player else { return }

        fadeTask?.cancel()

        fadeTask = Task {
            let steps: Float = 25

            for i in stride(from: 0, through: steps, by: 1) {
                guard !Task.isCancelled else { return }

                let newVolume = (Float(i) / steps) * target
                player.volume = min(newVolume, target)
                try? await Task.sleep(nanoseconds: 30_000_000)
            }

            player.volume = target
        }

        await fadeTask?.value
    }
}


// MARK: - NEXT SONG
extension MusicManager {

    private func skipToNextSong() async {
        guard !songs.isEmpty else { return }

        currentIndex = (currentIndex + 1) % songs.count
        print("⏭️ Weiter zu:", songs[currentIndex].title)

        await playSong(at: currentIndex, fadeIn: true)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { await skipToNextSong() }
    }
}


// MARK: - MODELS
struct SongList: Codable {
    let songs: [Song]
}

struct Song: Codable {
    let title: String
    let fileName: String
}

