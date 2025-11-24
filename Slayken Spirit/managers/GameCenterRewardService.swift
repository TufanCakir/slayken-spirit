//
//  GameCenterRewardService.swift
//  Slayken Spirit
//

import Foundation

final class GameCenterRewardService {

    static let shared = GameCenterRewardService()
    private init() {}

    private let storage = UserDefaults.standard

    // MARK: - Keys
    private func rewardGivenKey(for id: String, level: Int) -> String {
        return "reward_given_\(id)_\(level)"
    }

    // MARK: - Stage Rewards
    func rewardForStage(_ stage: Int) {

        let id = GCHighestStage.leaderboardID
        let key = rewardGivenKey(for: id, level: stage)
        if storage.bool(forKey: key) { return }

        switch stage {

        case 50:
            RewardManager.shared.give(.coins(300))

        case 100:
            RewardManager.shared.give(.crystals(300))


        case 200:
            RewardManager.shared.give(.exp(30))


        case 500:
            RewardManager.shared.give(.crystals(500))


        default:
            break
        }

        storage.set(true, forKey: key)
    }
    
    func reset() {
        let defaults = UserDefaults.standard

        for key in defaults.dictionaryRepresentation().keys {
            if key.starts(with: "reward_given_") {
                defaults.removeObject(forKey: key)
            }
        }

        print("🔄 GameCenterRewardService reset! Alle Belohnungs-Sperren gelöscht.")
    }


    // MARK: - Artefact Rewards
    func rewardForArtefacts(_ total: Int) {

        let id = GCArtefacts.leaderboardID
        let key = rewardGivenKey(for: id, level: total)
        if storage.bool(forKey: key) { return }

        switch total {
        case 10:
            RewardManager.shared.give(.crystals(3))

        case 25:
            RewardManager.shared.give(.exp(10))

        case 50:
            RewardManager.shared.give(.coins(30))


        case 100:
            RewardManager.shared.give(.crystals(30))


        default:
            break
        }

        storage.set(true, forKey: key)
    }

    // MARK: - Quest Rewards
    func rewardForQuests(_ total: Int) {

        let id = GCQuests.leaderboardID
        let key = rewardGivenKey(for: id, level: total)
        if storage.bool(forKey: key) { return }

        switch total {
        case 5:
            RewardManager.shared.give(.exp(30))

        case 10:
            RewardManager.shared.give(.coins(50))

        case 20:
            RewardManager.shared.give(.crystals(5))


        default:
            break
        }

        storage.set(true, forKey: key)
    }

    // MARK: - Kill Rewards
    func rewardForKills(_ kills: Int) {

        let id = GCKills.leaderboardID
        let key = rewardGivenKey(for: id, level: kills)
        if storage.bool(forKey: key) { return }

        switch kills {
        case 100:
            RewardManager.shared.give(.exp(50))

        case 500:
            RewardManager.shared.give(.coins(300))

        case 1000:
            RewardManager.shared.give(.crystals(500))
        default:
            break
        }

        storage.set(true, forKey: key)
    }

    // MARK: - Playtime Rewards
    func rewardForPlaytime(_ minutes: Int) {

        let id = GCPlaytime.leaderboardID
        let key = rewardGivenKey(for: id, level: minutes)
        if storage.bool(forKey: key) { return }

        switch minutes {
        case 60:
            RewardManager.shared.give(.exp(100))

        case 300:
            RewardManager.shared.give(.coins(500))

        case 600:
            RewardManager.shared.give(.crystals(300))
        default:
            break
        }

        storage.set(true, forKey: key)
    }
}
