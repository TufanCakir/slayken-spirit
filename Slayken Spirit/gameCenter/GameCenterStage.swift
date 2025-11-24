import Foundation

struct GCHighestStage {
    static let leaderboardID = "spirit_highest_stage"

    static func submit(_ value: Int) {
        GameCenterManager.shared.submit(score: value,
                                        leaderboardID: leaderboardID)
    }
}
