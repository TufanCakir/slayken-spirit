import Foundation

struct MultiplayerEvent: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let gridColor: String
    let bosses: [MultiplayerBoss]
    let category: MultiplayerCategory
}

enum MultiplayerCategory: String, Codable, CaseIterable {
    case raid
    case trial
    case special
    case duo
    case group
}


struct MultiplayerBoss: Codable, Identifiable {
    var id: String { modelNames.joined(separator: "_") }

    let modelNames: [String]

    let hp: MultiplayerValue
    let coins: MultiplayerValue
    let crystals: MultiplayerValue
    let exp: MultiplayerValue
}

enum MultiplayerValue: Codable {
    case single(Int)
    case multi([Int])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Int.self) {
            self = .single(v)
        } else if let arr = try? container.decode([Int].self) {
            self = .multi(arr)
        } else {
            throw DecodingError.typeMismatch(
                MultiplayerValue.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Int or [Int]"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let v): try container.encode(v)
        case .multi(let arr): try container.encode(arr)
        }
    }

    func value(at index: Int) -> Int {
        switch self {
        case .single(let v):
            return v

        case .multi(let arr):
            return arr[min(index, arr.count - 1)]
        }
    }
}

