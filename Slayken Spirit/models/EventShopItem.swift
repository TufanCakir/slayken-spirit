import Foundation

struct EventShopItem: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let price: Int
    let type: String
    let value: Int
}
