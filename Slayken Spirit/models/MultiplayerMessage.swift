import Foundation

struct MultiplayerMessage: Codable {
    let senderName: String
    let text: String
    let timestamp: Date
}
