import Foundation

extension Bundle {

    func loadArtefacts(_ filename: String) -> [Artefact] {

        guard let url = url(forResource: filename, withExtension: "json") else {
            print("❌ Artefakt-Datei fehlt: \(filename).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys

            let decoded = try decoder.decode([Artefact].self, from: data)

            print("🟣 \(decoded.count) Artefakte geladen.")
            return decoded

        } catch {
            print(
                "❌ Fehler beim Laden von \(filename).json:",
                error.localizedDescription
            )
            return []
        }
    }
}
