//
//  UpgradeManager.swift
//  Slayken Spirit
//

internal import Combine
import Foundation
import SwiftUI

@MainActor
final class UpgradeManager: ObservableObject {

    static let shared = UpgradeManager()

    // MARK: - Published Upgrade Werte
    @Published private(set) var tapDamage: Int
    @Published private(set) var lootChance: Double
    @Published private(set) var speed: Double

    @Published private(set) var expBoost: Int
    @Published private(set) var lootBoost: Double
    @Published private(set) var coinBoost: Int

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private struct Keys {
        static let tapDamage = "upgrade_tapDamage"
        static let lootChance = "upgrade_lootChance"
        static let speed = "upgrade_speed"

        static let expBoost = "upgrade_expBoost"
        static let lootBoost = "upgrade_lootBoost"
        static let coinBoost = "upgrade_coinBoost"
    }

    private struct Limits {
        static let maxLootChance = 0.50
        static let maxSpeed = 5.0
    }

    // MARK: Init
    init() {

        // PRIMÄRE Werte
        let savedTap = UserDefaults.standard.integer(forKey: Keys.tapDamage)
        let savedLoot = UserDefaults.standard.double(forKey: Keys.lootChance)
        let savedSpeed = UserDefaults.standard.double(forKey: Keys.speed)

        self.tapDamage = max(savedTap, 1)
        self.lootChance = savedLoot == 0 ? 0.01 : savedLoot
        self.speed = savedSpeed == 0 ? 1.0 : savedSpeed

        // EVENT SHOP Werte
        self.expBoost = UserDefaults.standard.integer(forKey: Keys.expBoost)
        self.lootBoost = UserDefaults.standard.double(forKey: Keys.lootBoost)
        self.coinBoost = UserDefaults.standard.integer(forKey: Keys.coinBoost)

        setupAutoSave()
    }

    // MARK: Upgrade Logic
    func upgradeTapDamage(cost: Int) {
        guard CoinManager.shared.spendCoins(cost) else { return }
        tapDamage += 1
    }

    func upgradeLootChance(cost: Int) {
        guard CoinManager.shared.spendCoins(cost) else { return }
        lootChance = min(lootChance + 0.01, Limits.maxLootChance)
    }

    func upgradeSpeed(cost: Int) {
        guard CoinManager.shared.spendCoins(cost) else { return }
        speed = min(speed + 0.1, Limits.maxSpeed)
    }

    // MARK: Event Shop Upgrade APIs
    func increaseTapDamage(by amount: Int) {
        tapDamage += amount
    }

    func increaseExpBoost(by amount: Int) {
        expBoost += amount
    }

    func increaseLootBoost(by amount: Double) {
        lootBoost += amount
    }

    func increaseCoinBoost(by amount: Int) {
        coinBoost += amount
    }

    // MARK: Reset
    func reset() {
        tapDamage = 1
        lootChance = 0.01
        speed = 1.0

        expBoost = 0
        lootBoost = 0
        coinBoost = 0

        save()
        objectWillChange.send()
    }

    // MARK: Save System
    private func setupAutoSave() {

        let primary = Publishers.CombineLatest4(
            $tapDamage,
            $lootChance,
            $speed,
            $expBoost
        )

        let secondary = Publishers.CombineLatest(
            $lootBoost,
            $coinBoost
        )

        Publishers.CombineLatest(primary, secondary)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }

    private func save() {
        UserDefaults.standard.set(tapDamage, forKey: Keys.tapDamage)
        UserDefaults.standard.set(lootChance, forKey: Keys.lootChance)
        UserDefaults.standard.set(speed, forKey: Keys.speed)

        UserDefaults.standard.set(expBoost, forKey: Keys.expBoost)
        UserDefaults.standard.set(lootBoost, forKey: Keys.lootBoost)
        UserDefaults.standard.set(coinBoost, forKey: Keys.coinBoost)
    }
}
