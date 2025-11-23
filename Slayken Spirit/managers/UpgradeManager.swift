//
//  UpgradeManager.swift
//  Slayken Spirit
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class UpgradeManager: ObservableObject {

    static let shared = UpgradeManager()

    // MARK: - Published Upgrade Werte
    @Published private(set) var tapDamage: Int
    @Published private(set) var lootChance: Double
    @Published private(set) var speed: Double

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private struct Keys {
        static let tapDamage = "upgrade_tapDamage"
        static let lootChance = "upgrade_lootChance"
        static let speed = "upgrade_speed"
    }

    private struct Limits {
        static let maxLootChance = 0.50
        static let maxSpeed = 5.0
    }

    // MARK: - Init
    private init() {

        // 1️⃣ geladene Werte in LOKALEN Variablen vorbereiten
        let savedTap = UserDefaults.standard.integer(forKey: Keys.tapDamage)
        let savedLoot = UserDefaults.standard.double(forKey: Keys.lootChance)
        let savedSpeed = UserDefaults.standard.double(forKey: Keys.speed)

        let initialTap = max(savedTap, 1)
        let initialLoot = savedLoot == 0 ? 0.01 : savedLoot
        let initialSpeed = savedSpeed == 0 ? 1.0 : savedSpeed

        // 2️⃣ Published Werte erst JETZT setzen
        self.tapDamage = initialTap
        self.lootChance = initialLoot
        self.speed = initialSpeed

        // 3️⃣ Autosave starten
        setupAutoSave()
    }

    // MARK: - Upgrade Logic
    func upgradeTapDamage(cost: Int) {
        guard CoinManager.shared.spendCoins(cost) else { return }
        tapDamage += 1
        print("⚔️ TapDamage erhöht: \(tapDamage)")
    }

    func upgradeLootChance(cost: Int) {
        guard CoinManager.shared.spendCoins(cost) else { return }
        lootChance = min(lootChance + 0.01, Limits.maxLootChance)
        print("🍀 LootChance erhöht: \(lootChance * 100)%")
    }

    func upgradeSpeed(cost: Int) {
        guard CoinManager.shared.spendCoins(cost) else { return }
        speed = min(speed + 0.1, Limits.maxSpeed)
        print("⚡ Speed erhöht: \(speed)x")
    }

    func reset() {
        tapDamage = 1
        lootChance = 0.01
        speed = 1.0

        save()
        objectWillChange.send()

        print("🔄 UpgradeManager reset! Alle Upgrades zurückgesetzt.")
    }


    // MARK: - Auto Save
    private func setupAutoSave() {
        Publishers.CombineLatest3($tapDamage, $lootChance, $speed)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _,_,_ in self?.save() }
            .store(in: &cancellables)
    }

    // MARK: - Save
    private func save() {
        UserDefaults.standard.set(tapDamage, forKey: Keys.tapDamage)
        UserDefaults.standard.set(lootChance, forKey: Keys.lootChance)
        UserDefaults.standard.set(speed, forKey: Keys.speed)
    }
}
