internal import Combine
import Foundation
internal import GameKit

@MainActor
final class GameCenterManager: NSObject, ObservableObject {

    static let shared = GameCenterManager()

    @Published var isAuthenticated = false
    @Published var playerName: String = "Not logged in"

    private override init() {}

    // MARK: - AUTHENTICATION
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] vc, error in
            guard let self else { return }

            if let error = error {
                print("❌ Game Center Error:", error.localizedDescription)
            }

            // Falls Game Center ein Login-View liefert (UIKit), logge Hinweis, aber präsentiere nichts
            if vc != nil {
                print(
                    "🔐 Login-UI wäre verfügbar, aber wird nicht automatisch gezeigt."
                )
                return
            }

            if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                self.playerName = GKLocalPlayer.local.displayName
                print("🎮 Eingeloggt als:", self.playerName)
            } else {
                self.isAuthenticated = false
                print("❌ Authentifizierung fehlgeschlagen")
            }
        }
    }

    // MARK: - Login manuell triggern (aber keine UI)
    func openGameCenterLogin() {
        authenticate()
    }

    // MARK: - Score Submission (ohne UI)
    func submit(score: Int, leaderboardID: String) {
        guard isAuthenticated else {
            print("⚠️ Kann Score nicht senden – nicht eingeloggt.")
            return
        }

        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        ) { error in
            if let error {
                print("❌ Fehler beim Senden:", error.localizedDescription)
            } else {
                print(
                    "🏆 Score erfolgreich gesendet →",
                    leaderboardID,
                    "Punkte:",
                    score
                )
            }
        }
    }
}
