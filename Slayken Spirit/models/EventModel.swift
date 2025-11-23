import Foundation

struct GameEvent: Identifiable, Codable {
    let id: String
    let name: String
    let spirit: String   // ID des Spirits
    let desc: String?
    let rarity: String?
    let icon: String?
}
extension Bundle {
    func loadEvents(_ filename: String = "events") -> [GameEvent] {
        guard let url = self.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([GameEvent].self, from: data) else {
            return []
        }
        return decoded
    }
}
