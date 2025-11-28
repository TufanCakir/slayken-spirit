import Foundation

final class GameCenterRewardService {

    static let shared = GameCenterRewardService()
    private init() {}

    private let storage = UserDefaults.standard

    // MARK: - Key Generator
    private func rewardGivenKey(for id: String, level: Int) -> String {
        return "reward_given_\(id)_\(level)"
    }

    // MARK: - Reset für Debug / Tests
    func reset() {
        for key in storage.dictionaryRepresentation().keys {
            if key.starts(with: "reward_given_") {
                storage.removeObject(forKey: key)
            }
        }
        print("🔄 GameCenterRewardService reset – alle Belohnungen freigegeben")
    }

    // MARK: - STAGE Belohnung
    func rewardForStage(_ stage: Int) {
        let id = GCHighestStage.leaderboardID
        checkAndGiveReward(id: id, level: stage) {
            switch stage {
            case 50: return RewardManager.coins(300)
            case 100: return RewardManager.crystals(300)
            case 200: return RewardManager.exp(30)
            case 500: return RewardManager.crystals(500)
            default: return nil
            }
        }
    }

    // MARK: - ARTEFAKT Belohnung
    func rewardForArtefacts(_ total: Int) {
        let id = GCArtefacts.leaderboardID
        checkAndGiveReward(id: id, level: total) {
            switch total {
            case 10: return RewardManager.crystals(3)
            case 25: return RewardManager.exp(10)
            case 50: return RewardManager.coins(30)
            case 100: return RewardManager.crystals(30)
            default: return nil
            }
        }
    }

    // MARK: - QUEST Belohnung
    func rewardForQuests(_ total: Int) {
        let id = GCQuests.leaderboardID
        checkAndGiveReward(id: id, level: total) {
            switch total {
            case 5: return RewardManager.exp(30)
            case 10: return RewardManager.coins(50)
            case 20: return RewardManager.crystals(5)
            default: return nil
            }
        }
    }

    // MARK: - KILL Belohnung
    func rewardForKills(_ kills: Int) {
        let id = GCKills.leaderboardID
        checkAndGiveReward(id: id, level: kills) {
            switch kills {
            case 100: return RewardManager.exp(50)
            case 500: return RewardManager.coins(300)
            case 1000: return RewardManager.crystals(500)
            default: return nil
            }
        }
    }

    // MARK: - SPIELZEIT Belohnung
    func rewardForPlaytime(_ minutes: Int) {
        let id = GCPlaytime.leaderboardID
        checkAndGiveReward(id: id, level: minutes) {
            switch minutes {
            case 60: return RewardManager.exp(100)
            case 300: return RewardManager.coins(500)
            case 600: return RewardManager.crystals(300)
            default: return nil
            }
        }
    }

    // MARK: - Intern: Helper
    private func checkAndGiveReward(
        id: String,
        level: Int,
        reward: () -> RewardManager.Reward?
    ) {
        let key = rewardGivenKey(for: id, level: level)
        guard !storage.bool(forKey: key) else { return }

        if let reward = reward() {
            RewardManager.shared.give(reward)
            storage.set(true, forKey: key)
            print("🎁 Belohnung vergeben für \(id) – Stufe \(level): \(reward)")
        }
    }
}
