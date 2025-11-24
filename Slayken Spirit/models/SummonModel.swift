import Foundation

struct SummonOption: Identifiable, Codable {
    let id: String
    let title: String
    let priceCrystals: Int
    let amount: Int
}

extension Bundle {
    func loadSummonOptions() -> [SummonOption] {
        guard let url = self.url(forResource: "summonData", withExtension: "json")
        else { fatalError("summonData.json fehlt!") }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([SummonOption].self, from: data)
        } catch {
            fatalError("Decoding summonData.json fehlgeschlagen: \(error)")
        }
    }
}
