import SwiftUI
import RealityKit

struct MultiModel3DView: View {

    let modelNames: [String]

    var body: some View {
        RealityView { content in
            let anchor = AnchorEntity(world: .zero)

            // Abstand zwischen Modellen
            let spacing: Float = 1.8
            let startX = -Float(modelNames.count - 1) * spacing / 2

            for (index, name) in modelNames.enumerated() {
                if let entity = try? await Entity(named: name) {
                    // Auf den Boden setzen
                    let bounds = entity.visualBounds(relativeTo: nil)
                    entity.position.y -= bounds.min.y

                    // Seitlich positionieren
                    entity.position.x = startX + Float(index) * spacing

                    // Einheitliche Präsentation
                    entity.scale = [0.7, 0.7, 0.7]
                    entity.orientation = simd_quatf(angle: -.pi/10, axis: [0,1,0])

                    anchor.addChild(entity)
                } else {
                    print("❌ Konnte Modell nicht laden:", name)
                }
            }

            // Licht
            let light = DirectionalLight()
            light.light.intensity = 1500
            light.orientation = simd_quatf(angle: -.pi/3, axis: [1,0,0])
            anchor.addChild(light)

            await content.add(anchor)
        }
        .frame(height: 350)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
