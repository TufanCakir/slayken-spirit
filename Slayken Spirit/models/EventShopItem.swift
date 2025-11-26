import Foundation

struct EventShopItem: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let price: Int
    let type: String
    
    var stack: Int
    var required: Int
    var isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, icon, price, type
        case stack, required, isActive
    }

    // Custom Decoder (für Default-Werte)
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id          = try c.decode(String.self, forKey: .id)
        name        = try c.decode(String.self, forKey: .name)
        description = try c.decode(String.self, forKey: .description)
        icon        = try c.decode(String.self, forKey: .icon)
        price       = try c.decode(Int.self, forKey: .price)
        type        = try c.decode(String.self, forKey: .type)

        // Default Werte falls JSON die nicht hat
        stack       = try c.decodeIfPresent(Int.self, forKey: .stack) ?? 0
        required    = try c.decodeIfPresent(Int.self, forKey: .required) ?? 50
        isActive    = try c.decodeIfPresent(Bool.self, forKey: .isActive) ?? false
    }

    // Encoder nicht überschreiben → Standard reicht
}
