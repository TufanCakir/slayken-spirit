import Foundation

struct GameButton: Codable, Identifiable {
    let id: String
    let type: String
    let title: String
    let icon: String
    let value: Double?

    // OPTIONAL + Default-Wert
    var isActive: Bool? = false
}

extension Bundle {
    func loadGameButtons() -> [GameButton] {
        guard
            let url = self.url(
                forResource: "gameButtons",
                withExtension: "json"
            )
        else { fatalError("❌ gameButtons.json fehlt") }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([GameButton].self, from: data)
        } catch {
            fatalError("❌ Fehler in gameButtons.json → \(error)")
        }
    }
}
