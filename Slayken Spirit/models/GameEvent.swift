import Foundation

struct GameEvent: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let gridColor: String
    let bosses: [EventBoss]
    let category: EventCategory
    let musicIndex: Int?      // 👈 NEU
}

enum EventCategory: String, Codable, CaseIterable {
    case raid
    case trial
    case special
}

struct EventBoss: Codable, Identifiable {
    var id: String { modelNames.joined(separator: "_") }

    let modelNames: [String]

    let hp: EventValue
    let coins: EventValue
    let crystals: EventValue
    let exp: EventValue
}

enum EventValue: Codable {
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
                EventValue.self,
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
