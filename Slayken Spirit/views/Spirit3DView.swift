import SwiftUI
import _RealityKit_SwiftUI
struct Spirit3DView: View {

    let modelName: String
    let rotation: Float
    let scale: Float

    var body: some View {
        RealityView { content in
            do {
                let anchor = AnchorEntity()

                guard let model = try? await Entity(named: modelName) else {
                    print("❌ Model not found:", modelName)
                    return
                }

                let bounds = model.visualBounds(relativeTo: model)
                model.position.y -= bounds.min.y
                model.scale = [scale, scale, scale]

                // Rotation
                model.orientation = simd_quatf(angle: rotation, axis: [0,1,0])

                // Light
                let light = DirectionalLight()
                light.light.intensity = 1500
                light.orientation = simd_quatf(angle: -.pi/3, axis: [1,0,0])

                anchor.addChild(light)
                anchor.addChild(model)
                content.add(anchor)

            } catch {
                print("❌ Spirit3DView Error:", error)
            }
        }
    }
}
