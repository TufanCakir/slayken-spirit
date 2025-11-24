import Foundation
internal import Combine
import SwiftUI

@MainActor
final class ArtefactInventoryManager: ObservableObject {

    static let shared = ArtefactInventoryManager()

    @Published private(set) var owned: [Artefact] = []

    private let saveKey = "ownedArtefacts"

    private init() {
        load()
    }

    // MARK: - Total Artefacts (für Game Center)
    /// Zählt alle Artefakte inklusive Level
    var total: Int {
        owned.reduce(0) { $0 + $1.level }
    }

    // MARK: - Optional: Collection Score
    var collectionScore: Int {
        owned.reduce(0) { score, art in
            score + artScore(art)
        }
    }

    private func artScore(_ art: Artefact) -> Int {
        switch art.rarity {
        case "common": return 1 * art.level
        case "rare": return 5 * art.level
        case "epic": return 15 * art.level
        case "legendary": return 40 * art.level
        default: return 1
        }
    }

    // MARK: - Artefact upgraden
    func upgrade(_ artefact: Artefact) {
        guard let index = owned.firstIndex(where: { $0.id == artefact.id }) else { return }

        owned[index].level += 1
        save()
        objectWillChange.send()
    }

    // MARK: - Artefact hinzufügen
    func addArtefact(_ artefact: Artefact) {
        if let index = owned.firstIndex(where: { $0.id == artefact.id }) {
            owned[index].level += 1
        } else {
            owned.append(artefact)
        }

        save()
        objectWillChange.send()
    }

    func reset() {
        owned.removeAll()
        UserDefaults.standard.removeObject(forKey: saveKey)
        objectWillChange.send()
        print("🔄 ArtefactInventoryManager reset! Alle Artefakte gelöscht.")
    }

    // MARK: - Bonus Werte
    var bonusTapDamage: Int {
        owned.filter { $0.types.contains("tap_damage") }
            .map { $0.totalPower }
            .reduce(0, +)
    }

    var bonusHP: Int {
        owned.filter { $0.types.contains("hp_bonus") }
            .map { $0.totalPower }
            .reduce(0, +)
    }

    var bonusExp: Int {
        owned.filter { $0.types.contains("exp_bonus") }
            .map { $0.totalPower }
            .reduce(0, +)
    }

    var bonusCoins: Int {
        owned.filter { $0.types.contains("coin_gain") }
            .map { $0.totalPower }
            .reduce(0, +)
    }

    var bonusAttackSpeed: Double {
        owned.filter { $0.types.contains("attack_speed") }
            .map { Double($0.totalPower) }
            .reduce(0, +)
    }

    var bonusLootBoost: Double {
        owned.filter { $0.types.contains("loot_boost") }
            .map { Double($0.totalPower) }
            .reduce(0, +)
    }

    var bonusCritChance: Double {
        owned.filter { $0.types.contains("crit_chance") }
            .map { Double($0.totalPower) }
            .reduce(0, +)
    }

    var bonusCritDamage: Double {
        owned.filter { $0.types.contains("crit_damage") }
            .map { Double($0.totalPower) }
            .reduce(0, +)
    }

    // MARK: - Save/load
    private func save() {
        if let data = try? JSONEncoder().encode(owned) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Artefact].self, from: data)
        else { return }

        owned = decoded
    }
}
