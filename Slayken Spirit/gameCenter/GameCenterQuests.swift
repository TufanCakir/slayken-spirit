import Foundation

/// 📜 Reicht abgeschlossene Quests bei Game Center ein – ohne UI
struct GCQuests {

    static let leaderboardID = "spirit_quests_completed"

    static func submit(_ value: Int) {
        guard value >= 0 else {
            print("⚠️ GCQuests: Wert darf nicht negativ sein.")
            return
        }

        GameCenterManager.shared.submit(
            score: value,
            leaderboardID: leaderboardID
        )
    }
}
