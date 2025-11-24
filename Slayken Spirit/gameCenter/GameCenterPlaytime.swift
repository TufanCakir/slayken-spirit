import Foundation

struct GCPlaytime {
    static let leaderboardID = "spirit_playtime_minutes"

    static func submit(_ minutes: Int) {
        GameCenterManager.shared.submit(score: minutes,
                                        leaderboardID: leaderboardID)
    }
}
