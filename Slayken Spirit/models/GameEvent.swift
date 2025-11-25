import Foundation

struct GameEvent: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let gridColor: String
    let bossId: String
}
