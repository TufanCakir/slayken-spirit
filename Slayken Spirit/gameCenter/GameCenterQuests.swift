import Foundation

struct GCQuests {
    static let leaderboardID = "spirit_quests_completed"

    static func submit(_ value: Int) {
        GameCenterManager.shared.submit(score: value,
                                        leaderboardID: leaderboardID)
    }
}
