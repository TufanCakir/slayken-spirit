// MARK: - MatchManager

internal import Combine
internal import GameKit

final class MatchManager: NSObject, ObservableObject, GKMatchDelegate {
    static let shared = MatchManager()
    
    // Veröffentlichte Variablen für die SwiftUI-Anzeige
    @Published var currentMatch: GKMatch? = nil
    @Published var isMatchActive = false
    @Published var connectedPlayers: [GKPlayer] = []
    
    // Speichert den Match-Status
    @Published var matchStateText: String = "Kein aktives Match"

    // ------------------------------------------------------------------
    // MARK: - START/BEENDEN
    // ------------------------------------------------------------------
    
    // Wird vom MatchmakerModalView.Coordinator aufgerufen
    func startMatch(_ match: GKMatch) {
        self.currentMatch = match
        self.currentMatch?.delegate = self // Wichtig: Match-Delegate setzen!
        
        // Füge den lokalen Spieler sofort hinzu
        var players = match.players
        players.append(GKLocalPlayer.local)
        
        self.connectedPlayers = players.sorted { $0.displayName < $1.displayName }
        self.isMatchActive = true
        self.matchStateText = "Match gefunden. Bereit zum Start!"
        
        // HIER würde der Navigationsschritt zu deiner SpiritGameView erfolgen,
        // die das MatchManager.shared Objekt nutzt.
    }
    
    // Die Funktion zum Verlassen des Matches
    func leaveMatch() {
        currentMatch?.disconnect() // Verbindung trennen
        
        // Zustände zurücksetzen
        currentMatch = nil
        isMatchActive = false
        connectedPlayers = []
        matchStateText = "Kein aktives Match"
        
        // Hier müsste die Navigation ZURÜCK ins Hauptmenü/MultiplayerView erfolgen
    }
    
    // ------------------------------------------------------------------
    // MARK: - GKMatchDelegate (Wird vom Match-Objekt aufgerufen)
    // ------------------------------------------------------------------
    
    // Spieler verbindet/trennt die Verbindung
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        
        switch state {
        case .connected:
            if !connectedPlayers.contains(player) {
                connectedPlayers.append(player)
                connectedPlayers.sort { $0.displayName < $1.displayName }
                matchStateText = "\(player.displayName) ist beigetreten."
            }
        case .disconnected:
            connectedPlayers.removeAll { $0.playerID == player.playerID }
            matchStateText = "\(player.displayName) hat den Kampf verlassen."
            
            // Wenn der letzte verbleibende Spieler geht, Match beenden
            if connectedPlayers.count <= 1 {
                leaveMatch()
            }
            
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    // Daten von einem anderen Spieler empfangen (Kampf, Farmen, Grinden)
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // HIER WIRD DIE SPIEL-LOGIK EINGEFÜHRT (Z.B. Angriffssynchronisation)
        print("📥 Daten empfangen von \(player.displayName).")
        
        // Beispiel: Daten deserialisieren und Aktionen ausführen
        // if let action = try? JSONDecoder().decode(GameAction.self, from: data) { ... }
    }
    
    // Fehler während des Matches
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("❌ Match-Fehler: \(error?.localizedDescription ?? "Unbekannt")")
        leaveMatch()
    }
    
    // ------------------------------------------------------------------
    // MARK: - DATEN SENDEN (Kampf/Farmen)
    // ------------------------------------------------------------------

    func sendActionData<T: Codable>(_ object: T, mode: GKMatch.SendDataMode = .reliable) {
        guard let match = currentMatch else { return }
        
        do {
            let data = try JSONEncoder().encode(object)
            // Send to all currently connected remote players
            try match.send(data, to: match.players, dataMode: mode)
        } catch {
            print("❌ Fehler beim Senden von Daten: \(error.localizedDescription)")
        }
    }
}

