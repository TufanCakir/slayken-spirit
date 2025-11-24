import Foundation

struct GCKills {
    static let leaderboardID = "spirit_total_kills"

    static func submit(_ value: Int) {
        GameCenterManager.shared.submit(score: value,
                                        leaderboardID: leaderboardID)
    }
}
