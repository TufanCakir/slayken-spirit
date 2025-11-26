import Foundation
import GameKit
import SwiftUI
internal import Combine

final class GameCenterManager: NSObject, ObservableObject, GKGameCenterControllerDelegate {

    static let shared = GameCenterManager()

    @Published var isAuthenticated = false
    private var authCompletion: ((Bool, GKPlayer?) -> Void)?
    @Published var playerName: String = "Not logged in"

    private override init() {
        super.init()
    }

    // MARK: – Authenticate (mit optionalem Completion)
    func authenticate(completion: ((Bool, GKPlayer?) -> Void)? = nil) {

        self.authCompletion = completion

        GKLocalPlayer.local.authenticateHandler = { viewController, error in

            if let error = error {
                print("❌ Game Center Error:", error.localizedDescription)
            }

            if let vc = viewController {
                // Auth UI anzeigen
                UIApplication.shared.windows.first?
                    .rootViewController?
                    .present(vc, animated: true)
                return
            }

            // Erfolgreich
            if GKLocalPlayer.local.isAuthenticated {
                print("🎮 Game Center Authenticated")
                self.isAuthenticated = true
                self.playerName = GKLocalPlayer.local.displayName
                self.authCompletion?(true, GKLocalPlayer.local)
                self.authCompletion = nil
                return
            }

       



            // Fehlgeschlagen
            print("❌ Game Center Authentication failed")
            self.isAuthenticated = false
            self.authCompletion?(false, nil)
            self.authCompletion = nil
        }
    }

    // MARK: – Submit Score
    func submit(score: Int, leaderboardID: String) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("⚠️ Cannot submit – Not authenticated.")
            return
        }

        let scoreObj = GKScore(leaderboardIdentifier: leaderboardID)
        scoreObj.value = Int64(score)

        GKScore.report([scoreObj]) { error in
            if let error = error {
                print("❌ Score Error:", error.localizedDescription)
            } else {
                print("🏆 Score submitted:", score, "→", leaderboardID)
            }
        }
    }

    // MARK: – Leaderboard anzeigen
    func showLeaderboard(id: String? = nil) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards

        if let id = id {
            gcVC.leaderboardIdentifier = id
        }

        UIApplication.shared.windows.first?
            .rootViewController?
            .present(gcVC, animated: true)
    }

    // MARK: – Dashboard öffnen
    func showDashboard() {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self

        UIApplication.shared.windows.first?
            .rootViewController?
            .present(gcVC, animated: true)
    }

    // MARK: – Delegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
