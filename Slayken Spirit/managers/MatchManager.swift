// MARK: - MatchManager.swift

import SwiftUI
internal import Combine
internal import GameKit

@MainActor
final class MatchManager: NSObject, ObservableObject, GKMatchDelegate {

    static let shared = MatchManager()

    // MARK: - Published States für SwiftUI
    @Published var currentMatch: GKMatch?
    @Published var isMatchActive = false
    @Published var connectedPlayers: [GKPlayer] = []
    @Published var matchStateText: String = "Kein aktives Match"

    
    let incomingMessages = PassthroughSubject<MultiplayerMessage, Never>()

    private override init() {
        super.init()
    }

    // MARK: - Match starten
    func startMatch(_ match: GKMatch) {
        self.currentMatch = match
        self.currentMatch?.delegate = self

        // Lokalen Spieler + Remote-Spieler kombinieren
        var players = match.players
        players.append(GKLocalPlayer.local)

        self.connectedPlayers = players.sorted { $0.displayName < $1.displayName }
        self.isMatchActive = true
        self.matchStateText = "Match gefunden. Bereit zum Start!"
    }

    // MARK: - Match beenden
    func leaveMatch() {
        currentMatch?.disconnect()

        currentMatch = nil
        isMatchActive = false
        connectedPlayers = []
        matchStateText = "Kein aktives Match"
    }

    // MARK: - GKMatchDelegate

    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // Versuche, eine Chat-Nachricht zu decodieren
        if let message = try? JSONDecoder().decode(MultiplayerMessage.self, from: data) {
            DispatchQueue.main.async {
                self.incomingMessages.send(message)
            }
            return
        }
    }

    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            if !connectedPlayers.contains(where: { $0.gamePlayerID == player.gamePlayerID }) {
                connectedPlayers.append(player)
                connectedPlayers.sort { $0.displayName < $1.displayName }
            }
            matchStateText = "\(player.displayName) ist beigetreten."

        case .disconnected:
            connectedPlayers.removeAll { $0.gamePlayerID == player.gamePlayerID }
            matchStateText = "\(player.displayName) hat das Match verlassen."
            if connectedPlayers.count <= 1 {
                leaveMatch()
            }

        case .unknown:
            // Optional: handle any transient/indeterminate state explicitly
            matchStateText = "Verbindungsstatus von \(player.displayName) ist unbekannt."

        @unknown default:
            // Future-proofing for any new states Apple might add
            matchStateText = "Unbekannter Verbindungsstatus von \(player.displayName)."
        }
    }

    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("❌ Match-Fehler: \(error?.localizedDescription ?? "Unbekannter Fehler")")
        leaveMatch()
    }

    // MARK: - Daten senden (z. B. Angriffe, Position, Skills)
    func sendActionData<T: Codable>(_ object: T, mode: GKMatch.SendDataMode = .reliable) {
        guard let match = currentMatch else { return }

        do {
            let data = try JSONEncoder().encode(object)
            try match.send(data, to: match.players, dataMode: mode)
        } catch {
            print("❌ Fehler beim Senden von Daten: \(error.localizedDescription)")
        }
    }
}

