//
//  RewardManager.swift
//

import Foundation

@MainActor
final class RewardManager {

    static let shared = RewardManager()
    private init() {
        loadArtefactCache()
    }

    // MARK: - Artefakte Cache (Performance++
    private var artefactCache: [String: Artefact] = [:]

    private func loadArtefactCache() {
        let list = Bundle.main.loadArtefacts("artefacts")
        for art in list {
            artefactCache[art.id] = art
        }
        print("📦 RewardManager: \(artefactCache.count) Artefakte gecached.")
    }

    // MARK: - Reward Typen
    enum Reward {
        case coins(Int)
        case crystals(Int)
        case exp(Int)
        case artefact(String)  // Artefakt-ID
        case shards(String, Int)  // Artefakt-ID + Shards
        case combine([Reward])
    }

    // MARK: - Reward vergeben
    func give(_ reward: Reward) {
        switch reward {

        case .coins(let amount):
            print("🟡 +\(amount) Coins")
            CoinManager.shared.addCoins(amount)

        case .crystals(let amount):
            print("🔷 +\(amount) Crystals")
            CrystalManager.shared.addCrystals(amount)

        case .exp(let amount):
            print("🟣 +\(amount) EXP")
            AccountLevelManager.shared.addExp(amount)

        case .artefact(let id):
            giveArtefact(id)

        case .shards(let id, let amount):
            giveShards(id: id, amount: amount)

        case .combine(let arr):
            print("🎁 Kombinierte Rewards:")
            arr.forEach { give($0) }
        }
    }

    // MARK: - Dedizierte Artefaktlogik
    private func giveArtefact(_ id: String) {
        guard let art = artefactCache[id] else {
            print("❌ RewardManager: Artefakt-ID '\(id)' nicht gefunden.")
            return
        }
        print("💎 Artefakt erhalten: \(art.name)")
        ArtefactInventoryManager.shared.addShards(
            for: art,
            amount: art.dropShardsAmount
        )
    }

    private func giveShards(id: String, amount: Int) {
        guard let art = artefactCache[id] else {
            print(
                "❌ RewardManager: Artefakt-ID '\(id)' nicht gefunden (shards)."
            )
            return
        }
        print("💠 +\(amount) Shards für: \(art.name)")
        ArtefactInventoryManager.shared.addShards(for: art, amount: amount)
    }

    // MARK: - Syntactic Sugar API
    static func coins(_ v: Int) -> Reward { .coins(v) }
    static func crystals(_ v: Int) -> Reward { .crystals(v) }
    static func exp(_ v: Int) -> Reward { .exp(v) }
    static func artefact(_ id: String) -> Reward { .artefact(id) }
    static func shards(_ id: String, _ amount: Int) -> Reward {
        .shards(id, amount)
    }

    /// Kombiniert beliebig viele Rewards
    static func combine(_ rewards: Reward...) -> Reward {
        .combine(rewards)
    }
}
