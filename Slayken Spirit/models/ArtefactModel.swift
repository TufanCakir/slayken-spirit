import Foundation
import SwiftUI

struct Artefact: Identifiable, Codable {

    // MARK: - JSON Felder
    let id: String
    let name: String
    let rarity: String
    let dropChance: Double
    let types: [String]
    let power: Int
    let desc: String
    let icon: String?

    // MARK: - Upgrade System
    var level: Int
    var shards: Int
    var shardsForNextLevel: Int
    var basePower: Int

    // MARK: - Berechneter Wert
    var totalPower: Int {
        basePower * level
    }

    // MARK: - Drop Shard Amount (je nach rarity)
    var dropShardsAmount: Int {
        switch rarity.lowercased() {
        case "common": return Int.random(in: 2...5)
        case "rare": return Int.random(in: 4...8)
        case "epic": return Int.random(in: 10...15)
        case "legendary": return Int.random(in: 18...25)
        default: return Int.random(in: 1...3)
        }
    }

    // MARK: - ICON
    var displayIcon: String {
        if let icon, !icon.isEmpty { return icon }
        if types.contains("tap_damage") { return "🔥" }
        if types.contains("hp_bonus") { return "❄️" }
        if types.contains("exp_bonus") { return "🟣" }
        if types.contains("coin_gain") { return "🪙" }
        return "✨"
    }

    // MARK: - Rarity Color
    var rarityColor: Color {
        switch rarity.lowercased() {
        case "rare": return Color.blue
        case "epic": return Color.purple
        case "legendary": return Color.yellow
        default: return Color.gray
        }
    }

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, name, rarity, dropChance, types, power, desc, icon
        case level, shards, shardsForNextLevel, basePower
    }

    // MARK: - Custom Decoder (für Default-Werte)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        rarity = try container.decode(String.self, forKey: .rarity)
        dropChance = try container.decode(Double.self, forKey: .dropChance)
        types = try container.decode([String].self, forKey: .types)
        power = try container.decode(Int.self, forKey: .power)
        desc = try container.decode(String.self, forKey: .desc)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)

        // MARK: - DEFAULT Werte wenn nicht im JSON
        basePower =
            try container.decodeIfPresent(Int.self, forKey: .basePower) ?? power
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 1
        shards = try container.decodeIfPresent(Int.self, forKey: .shards) ?? 0
        shardsForNextLevel =
            try container.decodeIfPresent(Int.self, forKey: .shardsForNextLevel)
            ?? 10
    }

    // MARK: - Encoder (automatisch)
}
