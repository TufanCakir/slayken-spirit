import Foundation
import simd

struct ModelConfig: Codable {
    let id: String
    let modelName: String
    let background: String?
    let scale: [Float]
    let position: [Float]
    let rotation: Rotation
    let camera: CameraConfig
    let light: LightConfig
    let facing: String?  // "right" oder "left"
    let hp: Int
    let next: String?
    let reward: Reward?  // ← NEU

    struct Rotation: Codable {
        let x: Float
        let y: Float
        let z: Float
    }

    struct CameraConfig: Codable {
        let position: [Float]
        let lookAt: [Float]
    }

    struct LightConfig: Codable {
        let intensity: Float
        let position: [Float]
    }

    struct Reward: Codable {
        let coins: Int
        let crystals: Int
        let exp: Int
    }
}

extension Bundle {

    /// Lädt EINEN ModelConfig (Datei: name.json)
    func loadSpirit(_ filename: String) -> ModelConfig {
        guard let url = self.url(forResource: filename, withExtension: "json")
        else {
            fatalError("❌ Datei \(filename).json nicht gefunden")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(ModelConfig.self, from: data)
        } catch {
            fatalError(
                "❌ Fehler beim Dekodieren von \(filename).json → \(error)"
            )
        }
    }

    /// Lädt MEHRERE ModelConfigs (Array in JSON)
    func loadSpiritArray(_ filename: String) -> [ModelConfig] {
        guard let url = self.url(forResource: filename, withExtension: "json")
        else {
            fatalError("❌ Datei \(filename).json nicht gefunden")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([ModelConfig].self, from: data)
        } catch {
            fatalError(
                "❌ Fehler beim Dekodieren von \(filename).json (Array) → \(error)"
            )
        }
    }
}
