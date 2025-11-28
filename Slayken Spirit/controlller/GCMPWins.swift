//
//  GCMPWins.swift
//  Slayken Spirit
//

import Foundation
internal import GameKit

enum GCMPWins {
    static let leaderboardID = "spirit_multiplayer_wins" // 👉 dein Leaderboard-ID aus App Store Connect

    static func submit(_ value: Int) {
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)

        GKScore.report([score]) { error in
            if let error = error {
                print("❌ GCMPWins: Fehler beim Übertragen: \(error.localizedDescription)")
            } else {
                print("✅ GCMPWins: \(value) Multiplayer-Siege übertragen")
            }
        }
    }
}
