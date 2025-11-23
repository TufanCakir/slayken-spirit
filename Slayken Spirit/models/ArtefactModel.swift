import Foundation
import SwiftUI

struct Artefact: Identifiable, Codable {

    // MARK: - JSON Felder
    let id: String
    let name: String
    let rarity: String
    let dropChance: Double
    let types: [String]      // 👈 ARRAY mit mehreren Effekten
    let power: Int
    let desc: String
    let icon: String?

    // MARK: - Upgrade Level
    var level: Int = 1   // Falls nicht im JSON → automatisch 1

    // MARK: - Skalierter Wert
    var totalPower: Int {
        power * level
    }

    // MARK: - ICON: SF Symbol oder Emoji fallback
    var displayIcon: String {
        // Wenn SF Symbol gesetzt ist → nutzen
        if let icon, !icon.isEmpty {
            return icon
        }

        // Fallback: Emoji abhängig vom Effekt
        if types.contains("tap_damage") { return "🔥" }
        if types.contains("hp_bonus")   { return "❄️" }
        if types.contains("exp_bonus")  { return "🟣" }
        if types.contains("coin_gain")  { return "🪙" }

        return "✨"
    }

    // MARK: - Farbcode je nach Rarity
    var rarityColor: Color {
        switch rarity.lowercased() {
        case "rare":      return .blue
        case "epic":      return .purple
        case "legendary": return .yellow
        default:          return .gray
        }
    }
}

extension Bundle {
    func loadArtefacts(_ filename: String) -> [Artefact] {
        guard let url = url(forResource: filename, withExtension: "json") else {
            print("❌ Artefakt-Datei fehlt: \(filename).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys

            let decoded = try decoder.decode([Artefact].self, from: data)

            print("🟣 \(decoded.count) Artefakte geladen.")
            return decoded

        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ JSON-Key fehlt: \(key.stringValue) in \(filename).json")
            print("→ \(context.debugDescription)")
            return []

        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Typ-Fehler bei \(type) in \(filename).json")
            print("→ \(context.debugDescription)")
            return []

        } catch {
            print("❌ Fehler beim Laden von \(filename).json: \(error)")
            return []
        }
    }
}
