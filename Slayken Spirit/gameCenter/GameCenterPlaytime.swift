import Foundation

/// ⏱️ Reicht die gesamte Spielzeit (in Minuten) bei Game Center ein – UI-frei
struct GCPlaytime {

    static let leaderboardID = "spirit_playtime_minutes"

    static func submit(_ minutes: Int) {
        guard minutes >= 0 else {
            print("⚠️ GCPlaytime: Minuten dürfen nicht negativ sein.")
            return
        }

        GameCenterManager.shared.submit(
            score: minutes,
            leaderboardID: leaderboardID
        )
    }
}
