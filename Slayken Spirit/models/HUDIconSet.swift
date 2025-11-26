import SwiftUI

struct HUDIcon: Codable {
    let symbol: String
    let color: String
}

struct HUDIconSet: Codable {
    let coin: HUDIcon
    let crystal: HUDIcon
    let shards: HUDIcon
    let level: HUDIcon
}



