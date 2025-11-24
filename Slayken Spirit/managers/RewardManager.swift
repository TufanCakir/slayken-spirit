//
//  RewardManager.swift
//

import Foundation

final class RewardManager {

    static let shared = RewardManager()
    private init() {}

    enum Reward {
        case coins(Int)
        case crystals(Int)
        case exp(Int)
        case artefact(String)
        case combine([Reward])
    }

    func give(_ reward: Reward) {
        switch reward {
        case .coins(let amount):
            CoinManager.shared.addCoins(amount)

        case .crystals(let amount):
            CrystalManager.shared.addCrystals(amount)

        case .exp(let amount):
            AccountLevelManager.shared.addExp(amount)

        case .artefact(let id):
            if let art = Bundle.main.loadArtefacts("artefacts").first(where: { $0.id == id }) {
                ArtefactInventoryManager.shared.addArtefact(art)
            }

        case .combine(let rewards):
            rewards.forEach { give($0) }
        }
    }

    // MARK: - Syntactic sugar
    static func coins(_ v: Int) -> Reward { .coins(v) }
    static func crystals(_ v: Int) -> Reward { .crystals(v) }
    static func exp(_ v: Int) -> Reward { .exp(v) }
    static func artefact(_ id: String) -> Reward { .artefact(id) }

    // RICHTIG: variadische Parameter
    static func combine(_ rewards: Reward...) -> Reward {
        return .combine(rewards)
    }
}
