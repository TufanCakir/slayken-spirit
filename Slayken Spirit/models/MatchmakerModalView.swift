import SwiftUI
internal import GameKit

// MARK: - UIKit Matchmaker Wrapper
struct MatchmakerModalView: UIViewControllerRepresentable {

    let minPlayers: Int
    let maxPlayers: Int

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> GKMatchmakerViewController {
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        request.inviteMessage = "Lass uns spielen!"

        let vc = GKMatchmakerViewController(matchRequest: request)!
        vc.matchmakerDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: GKMatchmakerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, GKMatchmakerViewControllerDelegate {

        let parent: MatchmakerModalView

        init(parent: MatchmakerModalView) {
            self.parent = parent
        }

        func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
            parent.dismiss()
            print("❌ Matchmaking abgebrochen")
        }

        func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                      didFailWithError error: Error) {
            parent.dismiss()
            print("❌ Matchmaker Fehler:", error.localizedDescription)
        }

        func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                      didFind match: GKMatch) {
            parent.dismiss()
            MatchManager.shared.startMatch(match)
            print("🎉 Match gefunden!")
        }
    }
}
