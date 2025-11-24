import Foundation

struct GCArtefacts {
    static let leaderboardID = "spirit_total_artefacts"

    static func submit(_ value: Int) {
        GameCenterManager.shared.submit(score: value,
                                        leaderboardID: leaderboardID)
    }
}
