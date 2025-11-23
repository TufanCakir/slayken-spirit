import SwiftUI
import RealityKit

struct SpiritView: View {

    let config: ModelConfig

    var body: some View {
        RealityView { content in
            do {

                // -------------------------------------------------------
                // MARK: MODEL (ohne Background)
                // -------------------------------------------------------
                let model = try await Entity(named: config.modelName)
                model.scale = SIMD3<Float>(config.scale) * 1.5
                let slightTurn = simd_quatf(angle: -.pi/15, axis: [0, 5, 0]) // -10°

                // Pivot auf Boden setzen
                let bounds = model.visualBounds(relativeTo: model)
                model.position.y -= bounds.min.y

                // Container (damit wir Rotation/LookAt anwenden können)
                let pivotParent = Entity()
                model.position += [0, -bounds.min.y, 0]
                pivotParent.addChild(model)
                pivotParent.position = SIMD3<Float>(config.position)

                pivotParent.position.z += 1.0
                // Facing aus JSON
                if let facing = config.facing?.lowercased() {
                    switch facing {
                    case "left":
                        pivotParent.orientation = simd_quatf(angle: .pi/2, axis: [0,1,0])
                    case "right":
                        pivotParent.orientation = simd_quatf(angle: -.pi/2, axis: [0,1,0])
                    default: break
                    }
                }
                
              

                // Anchor fürs Modell
                let modelAnchor = AnchorEntity(world: .zero)
                modelAnchor.addChild(pivotParent)
                content.add(modelAnchor)
                
              
             

                // -------------------------------------------------------
                // MARK: CAMERA
                // -------------------------------------------------------
                let cam = PerspectiveCamera()

                let camPos = SIMD3<Float>(config.camera.position)
                let camLook = SIMD3<Float>(config.camera.lookAt)

                cam.position = camPos
                cam.look(at: camLook, from: camPos, relativeTo: nil)

                let camAnchor = AnchorEntity(world: .zero)
                camAnchor.addChild(cam)
                content.add(camAnchor)



                // -------------------------------------------------------
                // MARK: MODEL FACING CAMERA (optional)
                // -------------------------------------------------------
                let modelWorld = pivotParent.position(relativeTo: nil)
                let camWorld = cam.position(relativeTo: nil)

                let dir = normalize(camWorld - modelWorld)
                let up = SIMD3<Float>(0, 1, 0)
                let right = normalize(cross(up, dir))
                let correctedUp = cross(dir, right)

                var lookMatrix = float4x4()
                lookMatrix.columns.0 = SIMD4<Float>(right, 0)
                lookMatrix.columns.1 = SIMD4<Float>(correctedUp, 0)
                lookMatrix.columns.2 = SIMD4<Float>(dir, 0)
                lookMatrix.columns.3 = SIMD4<Float>(.zero, 1)

                let lookRotation = simd_quatf(lookMatrix)

               

                pivotParent.orientation = lookRotation * slightTurn



                // -------------------------------------------------------
                // MARK: LIGHT (von vorne)
                // -------------------------------------------------------
                let light = PointLight()
                light.light.intensity = config.light.intensity
                light.position = SIMD3<Float>(config.light.position)

                camAnchor.addChild(light)

            } catch {
                print("❌ RealityKit Fehler:", error.localizedDescription)
            }
        }
        .ignoresSafeArea()
    }
}
