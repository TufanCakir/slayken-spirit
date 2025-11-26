import Foundation

struct GCArtefacts {

    // MARK: - Leaderboard Identifier
    static let leaderboardID = "spirit_total_artefacts"

    // MARK: - Submit Score
    static func submit(_ value: Int) {
        guard value >= 0 else {
            print("❌ GCArtefacts.submit: Score darf nicht negativ sein.")
            return
        }

        GameCenterManager.shared.submit(
            score: value,
            leaderboardID: leaderboardID
        )
    }
}
