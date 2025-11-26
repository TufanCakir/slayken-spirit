import Foundation
internal import Combine
import SwiftUI

@MainActor
final class ArtefactInventoryManager: ObservableObject {

    static let shared = ArtefactInventoryManager()

    @Published private(set) var owned: [Artefact] = []

    private let saveKey = "ownedArtefacts"

    init() {
        load()
    }
    




    // MARK: - Total Stats (für Game Center)
    var total: Int {
        owned.reduce(0) { $0 + $1.level }
    }

    var totalShards: Int {
        owned.reduce(0) { $0 + $1.shards }
    }

    var collectionScore: Int {
        owned.reduce(0) { $0 + artScore($1) }
    }

    private func artScore(_ art: Artefact) -> Int {
        switch art.rarity.lowercased() {
        case "common": return art.level * 1
        case "rare": return art.level * 5
        case "epic": return art.level * 15
        case "legendary": return art.level * 40
        default: return art.level
        }
    }


    // MARK: - Kosten
      private func startingShardCost(for art: Artefact) -> Int {
          switch art.rarity.lowercased() {
          case "common": return 10
          case "rare": return 20
          case "epic": return 35
          case "legendary": return 60
          default: return 10
          }
      }


    // MARK: - Upgrade
      func upgrade(byID id: String) {
          guard let index = owned.firstIndex(where: { $0.id == id }) else { return }

          var item = owned[index]

          guard item.shards >= item.shardsForNextLevel else {
              print("❌ Nicht genug Shards: \(item.shards)/\(item.shardsForNextLevel)")
              return
          }

          item.shards -= item.shardsForNextLevel
          item.level += 1
          item.shardsForNextLevel = Int(Double(item.shardsForNextLevel) * 1.45)

          owned[index] = item
          save()
          objectWillChange.send()   // UI sofort aktualisieren
      }



    // MARK: - Add Shards (richtige Version!)
    func addShards(for art: Artefact, amount: Int) {
        guard amount > 0 else { return }

        if let index = owned.firstIndex(where: { $0.id == art.id }) {
            owned[index].shards += amount
        } else {
            var new = art
            new.level = 1
            new.shards = amount
            new.shardsForNextLevel = startingShardCost(for: new)
            owned.append(new)
        }

        save()
        objectWillChange.send()
    }


    // MARK: - Reset
    func reset() {
        owned.removeAll()
        UserDefaults.standard.removeObject(forKey: saveKey)
        print("🔄 Reset: Alle Artefakte gelöscht.")
    }


    // MARK: - Bonus Stats
    var bonusTapDamage: Int {
        totalBonus(forType: "tap_damage")
    }

    var bonusHP: Int {
        totalBonus(forType: "hp_bonus")
    }

    var bonusExp: Int {
        totalBonus(forType: "exp_bonus")
    }

    var bonusCoins: Int {
        totalBonus(forType: "coin_gain")
    }

    var bonusAttackSpeed: Double {
        Double(totalBonus(forType: "attack_speed"))
    }

    var bonusLootBoost: Double {
        Double(totalBonus(forType: "loot_boost"))
    }

    var bonusCritChance: Double {
        Double(totalBonus(forType: "crit_chance"))
    }

    var bonusCritDamage: Double {
        Double(totalBonus(forType: "crit_damage"))
    }

    private func totalBonus(forType type: String) -> Int {
        owned.filter { $0.types.contains(type) }
            .map { $0.totalPower }
            .reduce(0, +)
    }


    // MARK: - Save
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
