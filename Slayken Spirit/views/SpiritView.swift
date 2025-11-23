import SwiftUI
import RealityKit

struct SpiritView: View {

    let config: ModelConfig   // 👈 Jetzt extern übergeben!

    
    var body: some View {
        RealityView { content in
            do {

                // -------------------------------------------------------
                // MARK: BACKGROUND PLANE
                // -------------------------------------------------------
                if let bgName = config.background,
                   let uiImage = UIImage(named: bgName),
                   let cgImage = uiImage.cgImage {

                    let texture = try await TextureResource(
                        image: cgImage,
                        withName: bgName,
                        options: .init(semantic: .color)
                    )

                    var material = UnlitMaterial()
                    material.color = .init(texture: .init(texture))

                    let width: Float = 6
                    let aspect = Float(uiImage.size.height / uiImage.size.width)
                    let height: Float = width * aspect

                    let plane = ModelEntity(
                        mesh: .generatePlane(width: width, height: height),
                        materials: [material]
                    )

                    plane.position = [0, 0, -2]

                    let bgAnchor = AnchorEntity(world: .zero)
                    bgAnchor.addChild(plane)
                    content.add(bgAnchor)
                }

                // -------------------------------------------------------
                // MARK: MODEL
                // -------------------------------------------------------
                let model = try await Entity(named: config.modelName)
                model.scale = SIMD3<Float>(config.scale) * 1.5

                let bounds = model.visualBounds(relativeTo: model)

                let pivotParent = Entity()
                model.position += [0, -bounds.min.y, 0]
                pivotParent.addChild(model)

                pivotParent.position = SIMD3<Float>(config.position)
                pivotParent.position.z += 1.0

                // Facing
                if let facing = config.facing?.lowercased() {
                    switch facing {
                    case "left":
                        pivotParent.orientation = simd_quatf(angle: .pi/2, axis: [0,1,0])
                    case "right":
                        pivotParent.orientation = simd_quatf(angle: -.pi/2, axis: [0,1,0])
                    default: break
                    }
                }

                let modelAnchor = AnchorEntity(world: .zero)
                modelAnchor.addChild(pivotParent)
                content.add(modelAnchor)


                // -------------------------------------------------------
                // MARK: CAMERA
                // -------------------------------------------------------
                let cam = PerspectiveCamera()
                let pos = SIMD3<Float>(config.camera.position)
                let look = SIMD3<Float>(config.camera.lookAt)
      

                cam.position = pos
                cam.look(at: look, from: pos, relativeTo: nil)

                let camAnchor = AnchorEntity(world: .zero)
                camAnchor.addChild(cam)
                content.add(camAnchor)


                // -------------------------------------------------------
                // MARK: MODEL FACING CAMERA
                // -------------------------------------------------------
                let modelWorldPosition = pivotParent.position(relativeTo: nil)
                let cameraWorldPosition = cam.position(relativeTo: nil)

                let direction = normalize(cameraWorldPosition - modelWorldPosition)
                let up = SIMD3<Float>(0, 1, 0)
                let right = normalize(cross(up, direction))
                let correctedUp = cross(direction, right)

                var lookMatrix = simd_float4x4()
                lookMatrix.columns.0 = SIMD4<Float>(right, 0)
                lookMatrix.columns.1 = SIMD4<Float>(correctedUp, 0)
                lookMatrix.columns.2 = SIMD4<Float>(direction, 0)
                lookMatrix.columns.3 = SIMD4<Float>(.zero, 1)

                let lookRotation = simd_quatf(lookMatrix)

                // 🔥 leichte extra Drehung (z. B. 15° rechts)
                let slightTurn = simd_quatf(angle: -.pi/15, axis: [0, 5, 0]) // -10°


                // final → Kamera-Orientierung + cooler leichter Twist
                pivotParent.orientation = lookRotation * slightTurn

                // -------------------------------------------------------
                // MARK: LIGHT FIXED TO CAMERA (BEST)
                // -------------------------------------------------------
                let l = config.light

                let light = PointLight()
                light.light.intensity = l.intensity
                light.light.attenuationRadius = 55    // 🔥 Reichweite erhöhen
                light.position = [0, 0, 0]             // Licht sitzt bei Kamera

                // Licht an Kamera heften!
                camAnchor.addChild(light)

            } catch {
                print("❌ RealityKit Fehler:", error.localizedDescription)
            }
        }
        .ignoresSafeArea()
    }
}

