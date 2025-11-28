import Foundation

struct MultiplayerMessage: Codable {
    let senderName: String
    let text: String
    let timestamp: Date
}

// Im eigenen Modul oder Datei
enum MultiplayerAction: Codable {
    case chatMessage(MultiplayerMessage)
    case attack
    case bossDefeated
    // ... weitere Aktionen

    enum CodingKeys: String, CodingKey {
        case type, payload
    }

    enum ActionType: String, Codable {
        case chatMessage, attack, bossDefeated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)

        switch type {
        case .chatMessage:
            let message = try container.decode(MultiplayerMessage.self, forKey: .payload)
            self = .chatMessage(message)
        case .attack:
            self = .attack
        case .bossDefeated:
            self = .bossDefeated
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .chatMessage(let message):
            try container.encode(ActionType.chatMessage, forKey: .type)
            try container.encode(message, forKey: .payload)
        case .attack:
            try container.encode(ActionType.attack, forKey: .type)
        case .bossDefeated:
            try container.encode(ActionType.bossDefeated, forKey: .type)
        }
    }
}
