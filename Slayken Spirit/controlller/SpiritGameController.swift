//
//  SpiritGameController.swift
//  Slayken Spirit
//

import Foundation
internal import Combine

@MainActor
final class SpiritGameController: ObservableObject {


    // MARK: - Published: UI States
    @Published private(set) var current: ModelConfig
    @Published private(set) var currentHP: Int
    @Published private(set) var stage: Int = {
        let saved = UserDefaults.standard.integer(forKey: "savedStage")
        return max(saved, 1) // nie 0
    }()
    @Published private(set) var backgroundName: String
    @Published var backgroundFade: Double = 0
    @Published var isAutoBattle: Bool = false

    private var autoBattleTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Data
    private let all: [ModelConfig]

    // MARK: - Init
    init() {

        let loaded = Bundle.main.loadSpiritArray("spirits")
        guard let first = loaded.first else {
            fatalError("❌ spirits.json hat keine Einträge")
        }

        self.all = loaded
        self.current = first
        self.currentHP = first.hp + ArtefactInventoryManager.shared.bonusHP
        self.backgroundName = first.background ?? "sky"

        setupArtefactListener()
    }
    


    // MARK: - Artefact Change Listener
    private func setupArtefactListener() {
        ArtefactInventoryManager.shared.objectWillChange
            .sink { [weak self] _ in
                guard let self else { return }
                self.recalculateHP()
            }
            .store(in: &cancellables)
    }

    private func recalculateHP() {
        currentHP = max(1, current.hp + ArtefactInventoryManager.shared.bonusHP)
        objectWillChange.send()
    }



    // MARK: - Player Tap
    func tapAttack() {
        guard currentHP > 0 else { return }

        let base = UpgradeManager.shared.tapDamage + ArtefactInventoryManager.shared.bonusTapDamage
        let damage = calculateDamage(base: base)
        currentHP = max(0, currentHP - damage)

        if currentHP == 0 {
            handleDefeat()
        }
    }

    // MARK: - Crit System
    private func calculateDamage(base: Int) -> Int {

        let critChance = ArtefactInventoryManager.shared.bonusCritChance
        let critDamage = ArtefactInventoryManager.shared.bonusCritDamage

        let roll = Double.random(in: 0...100)

        if roll <= critChance {
            return Int(Double(base) * (1 + critDamage / 100.0))
        }

        return base
    }

    // MARK: - AutoBattle
    func toggleAutoBattle() {
        isAutoBattle.toggle()
        isAutoBattle ? startAutoBattle() : stopAutoBattle()
    }

    private func startAutoBattle() {

        stopAutoBattle()

        let speedPercent = ArtefactInventoryManager.shared.bonusAttackSpeed
        let interval = max(0.05, 0.18 * (1 - speedPercent / 100))

        autoBattleTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.currentHP > 0 {
                    self.tapAttack()
                } else {
                    self.stopAutoBattle()
                }
            }
        }

        RunLoop.main.add(autoBattleTimer!, forMode: .common)
    }

    private func stopAutoBattle() {
        autoBattleTimer?.invalidate()
        autoBattleTimer = nil
    }

    // MARK: - Defeat
    private func handleDefeat() {
        giveReward()
        rollArtefactDrop()
        goToNext()
    }

    // MARK: - Artefact Drop
    private func rollArtefactDrop() {

        let artefacts = Bundle.main.loadArtefacts("artefacts")
        let lootBoost = ArtefactInventoryManager.shared.bonusLootBoost

        for art in artefacts {
            var chance = art.dropChance + (lootBoost / 100.0)
            chance = min(chance, 0.95) // Hard cap
            if Double.random(in: 0...1) <= chance {
                ArtefactInventoryManager.shared.addArtefact(art)
            }
        }
    }

    // MARK: - Rewards
    private func giveReward() {
        guard let reward = current.reward else { return }

        let expBonus = ArtefactInventoryManager.shared.bonusExp
        let coinBonus = ArtefactInventoryManager.shared.bonusCoins

        CoinManager.shared.addCoins(reward.coins + coinBonus)
        CrystalManager.shared.addCrystals(reward.crystals)
        AccountLevelManager.shared.addExp(reward.exp + expBonus)
    }

    // MARK: - Next Spirit (automatisch per Reihenfolge)
    private func goToNext() {

        // Index finden
        guard let idx = all.firstIndex(where: { $0.id == current.id }) else { return }

        let nextIndex = (idx + 1) % all.count
        let next = all[nextIndex]

        stage += 1
        UserDefaults.standard.set(stage, forKey: "savedStage")
        current = next
        recalculateHP()

        updateBackground(for: next)
    }

    // MARK: - Background Change
    private func updateBackground(for next: ModelConfig) {

        let newBG = next.background ?? "sky"
        guard newBG != backgroundName else { return }

        backgroundFade = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.backgroundName = newBG
            self.backgroundFade = 0
        }
    }
}

