import Foundation

/// 🔹 Reicht den Sammlungsscore (Collection Score) bei Game Center ein – ohne UI
struct GCCollection {

    static let leaderboardID = "spirit_collection_score"

    /// Reicht einen gültigen Score bei Game Center ein
    static func submit(_ value: Int) {
        guard value >= 0 else {
            print("⚠️ GCCollection: Score darf nicht negativ sein.")
            return
        }

        GameCenterManager.shared.submit(
            score: value,
            leaderboardID: leaderboardID
        )
    }
}
