import Foundation

/// 📶 Reicht die höchste erreichte Stage bei Game Center ein – ohne UI
struct GCHighestStage {

    static let leaderboardID = "spirit_highest_stage"

    static func submit(_ value: Int) {
        guard value >= 0 else {
            print("⚠️ GCHighestStage: Wert darf nicht negativ sein.")
            return
        }

        GameCenterManager.shared.submit(
            score: value,
            leaderboardID: leaderboardID
        )
    }
}
