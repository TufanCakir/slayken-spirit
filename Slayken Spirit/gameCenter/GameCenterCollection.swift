import Foundation

struct GCCollection {
    static let leaderboardID = "spirit_collection_score"

    static func submit(_ value: Int) {
        GameCenterManager.shared.submit(score: value,
                                        leaderboardID: leaderboardID)
    }
}
