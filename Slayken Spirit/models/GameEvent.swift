import Foundation

struct GameEvent: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let image: String
    let bossId: String
}
