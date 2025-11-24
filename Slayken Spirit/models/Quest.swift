import Foundation

struct Quest: Identifiable, Codable {
    let id: String
    let name_de: String
    let name_en: String
    let desc_de: String
    let desc_en: String
    let type: String
    let target: Int
    let reward: QuestReward
}

struct QuestReward: Codable {
    let coins: Int
    let crystals: Int
    let exp: Int
    let artefact: String?
}
