import Foundation

/// Represents a single Spirit definition from `spirits.json`.
/// Fully resilient against missing JSON fields.
/// Automatically generates a stable ID if not provided.
public struct Spirit: Identifiable, Codable, Hashable {

    // MARK: - Stable Identity
    public let id: String  // Always present
    public let name: String  // Always present

    // MARK: - Optional metadata
    public let desc: String?  // Optional description
    public let imageName: String?  // Optional icon
    public let rarity: Rarity?  // Enum-based rarity (optional)

    // MARK: - Rarity Enum (Optional & Safe)
    public enum Rarity: String, Codable, CaseIterable {
        case common
        case rare
        case epic
        case legendary
        case mythic

        /// Default fallback for unknown or missing values
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let raw = (try? container.decode(String.self))?.lowercased()

            self = Rarity(rawValue: raw ?? "") ?? .common
        }
    }

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case desc = "description"
        case imageName
        case rarity
    }

    // MARK: - Custom Init (Decode + Normalize)
    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Required name
        let name = try container.decode(String.self, forKey: .name)

        // Auto-generate ID if missing
        let id =
            try container.decodeIfPresent(String.self, forKey: .id)
            ?? name
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")

        let desc = try container.decodeIfPresent(String.self, forKey: .desc)
        let imageName = try container.decodeIfPresent(
            String.self,
            forKey: .imageName
        )

        // Decode rarity safely (avoids crashes)
        let rarity = try? container.decode(Rarity.self, forKey: .rarity)

        self.init(
            id: id,
            name: name,
            desc: desc,
            imageName: imageName,
            rarity: rarity
        )
    }

    // MARK: - Direct initializer (Swift usage)
    public init(
        id: String,
        name: String,
        desc: String? = nil,
        imageName: String? = nil,
        rarity: Rarity? = nil
    ) {
        self.id = id
        self.name = name
        self.desc = desc
        self.imageName = imageName
        self.rarity = rarity
    }
}
