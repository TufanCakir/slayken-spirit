import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SummonController: ObservableObject {

    @Published var options: [SummonOption] = []
    @Published var summonResults: [String] = []   // IDs deiner Spirits o. Items
    @Published var showResult = false

    private let coin = CoinManager.shared
    private let crystal = CrystalManager.shared

    init() {
        options = Bundle.main.loadSummonOptions()
    }

    // Summon-Prozess
    func summon(_ option: SummonOption) {

        // Preisprüfungen
        if !coin.spendCoins(option.priceCoins) { return }
        if !crystal.spendCrystals(option.priceCrystals) { return }

        // Fake Zufallsziele (du kannst hier deine Spirit-IDs einfügen)
        let allSpirits = ["spirit_fire", "spirit_ice", "spirit_void"]

        summonResults.removeAll()

        for _ in 0..<option.amount {
            if let random = allSpirits.randomElement() {
                summonResults.append(random)
            }
        }

        showResult = true
    }
}
