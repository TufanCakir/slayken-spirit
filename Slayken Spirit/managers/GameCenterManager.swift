import Foundation
import GameKit
import SwiftUI
internal import Combine

@MainActor
final class GameCenterManager: NSObject, ObservableObject {

    static let shared = GameCenterManager()

    @Published var isAuthenticated = false
    @Published var playerName: String = "Not logged in"

    private override init() { }


    // ------------------------------------------------------------
    // MARK: - AUTHENTICATION
    // ------------------------------------------------------------
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] vc, error in
            guard let self else { return }

            if let error = error {
                print("❌ Game Center Error:", error.localizedDescription)
            }

            // Falls Game Center ein Login-Fenster liefert → anzeigen
            if let vc = vc {
                self.present(vc)
                return
            }

            // Erfolgreich eingeloggt
            if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                self.playerName = GKLocalPlayer.local.displayName
                print("🎮 Logged in as:", self.playerName)
            } else {
                // Nicht eingeloggt
                self.isAuthenticated = false
                print("❌ Auth failed")
            }
        }
    }


    // ------------------------------------------------------------
    // MARK: - MANUELLES LOGIN „Öffnen“
    // ------------------------------------------------------------
    func openGameCenterLogin() {
        // Dieses Login-Popup stammt IMMER aus authenticateHandler
        authenticate()
    }


    // ------------------------------------------------------------
    // MARK: - SCORE SUBMISSION (iOS 16+ modern)
    // ------------------------------------------------------------
    func submit(score: Int, leaderboardID: String) {
        guard isAuthenticated else {
            print("⚠️ Cannot submit score — user not authenticated.")
            return
        }

        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        ) { error in
            if let error {
                print("❌ Submit error:", error.localizedDescription)
            } else {
                print("🏆 Score submitted:", score, "→", leaderboardID)
            }
        }
    }


    // ------------------------------------------------------------
    // MARK: - LEADERBOARD ÖFFNEN (iOS 26+ deep-link)
    // ------------------------------------------------------------
    func showLeaderboard(id: String) {

        guard isAuthenticated else {
            print("⚠️ Not authenticated → cannot open leaderboard.")
            return
        }

        // Game Center URL-Schema (offiziell von Apple ab iOS 16+)
        if let url = URL(string: "gamecenter:leaderboard?id=\(id)") {
            UIApplication.shared.open(url)
        }
    }


    // ------------------------------------------------------------
    // MARK: - GAME CENTER DASHBOARD
    // ------------------------------------------------------------
    func showDashboard() {

        guard isAuthenticated else {
            print("⚠️ Not authenticated → cannot open dashboard.")
            return
        }

        if let url = URL(string: "gamecenter:dashboard") {
            UIApplication.shared.open(url)
        }
    }


    // ------------------------------------------------------------
    // MARK: - HELPER: TOP VIEW CONTROLLER
    // ------------------------------------------------------------
    private func present(_ vc: UIViewController) {
        guard let top = topMostViewController() else {
            print("❌ No root view controller found")
            return
        }
        top.present(vc, animated: true)
    }

    private func topMostViewController() -> UIViewController? {

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let root = window.rootViewController else {
            return nil
        }

        var top = root
        while let next = top.presentedViewController {
            top = next
        }
        return top
    }
}
