import SwiftUI
import RealityKit
import ARKit

struct ARSpiritBattleView: UIViewRepresentable {

    @ObservedObject var matchManager = MatchManager.shared
    let config: ModelConfig

    func makeCoordinator() -> Coordinator {
        Coordinator(config: config)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // MARK: - AR Session Setup
        let sessionConfig = ARWorldTrackingConfiguration()
        sessionConfig.planeDetection = [.horizontal]
        sessionConfig.environmentTexturing = .automatic
        sessionConfig.sceneReconstruction = .mesh
        arView.session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])

        // MARK: - Tap Gesture
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)

        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}


// MARK: - Coordinator
class Coordinator: NSObject {

    weak var arView: ARView?
    let config: ModelConfig
    private var placedOnce = false     // verhindert mehrfaches Spawn

    init(config: ModelConfig) {
        self.config = config
    }

    // MARK: - Place Model
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = arView else { return }

        let location = gesture.location(in: view)

        // MARK: - Raycast
        guard let result = view.raycast(
            from: location,
            allowing: .estimatedPlane,
            alignment: .horizontal
        ).first else {
            print("❌ Kein Boden gefunden")
            return
        }

        // Nur einmal platzieren
        if placedOnce { return }
        placedOnce = true

        placeModel(at: result.worldTransform, in: view)
    }

    // MARK: - Place entity
    private func placeModel(at transform: simd_float4x4, in view: ARView) {

        let anchor = AnchorEntity(world: transform)

        Task {
            do {
                let model = try await Entity(named: config.modelName)

                // MARK: - Auto-Leveling (damit nie im Boden versinkt)
                let bounds = model.visualBounds(relativeTo: nil)
                model.position.y -= bounds.min.y

                // MARK: - Scale
                model.scale = SIMD3<Float>(config.scale)

                // MARK: - Optional: Animation starten
                if let anim = model.availableAnimations.first {
                    model.playAnimation(anim.repeat())
                }

                // MARK: - Add to anchor
                anchor.addChild(model)

                // MARK: - Scene Light
                let sun = DirectionalLight()
                sun.light.intensity = config.light.intensity
                sun.light.color = .white
                sun.orientation = simd_quatf(angle: -.pi / 3, axis: [1, 0, 0])
                anchor.addChild(sun)

                view.scene.addAnchor(anchor)
                print("🔥 AR Boss platziert → \(config.modelName)")

            } catch {
                print("❌ Konnte Modell nicht laden: \(error.localizedDescription)")
            }
        }
    }
}
