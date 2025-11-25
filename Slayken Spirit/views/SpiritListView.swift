import SwiftUI
import SceneKit

struct SpiritCardView: View {
    let spirit: ModelConfig   // ← richtig!

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.2)
                )
                .shadow(color: .black.opacity(0.4), radius: 10, y: 6)

            VStack(spacing: 12) {

                Spirit3DMini(modelName: spirit.modelName)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(14)
        }
        .padding(.horizontal, 4)
    }
}



struct Spirit3DMini: View {
    let modelName: String

    @State private var scene = SCNScene()
    @State private var modelNode: SCNNode?

    @State private var rotX: Float = -0.1     // Pitch (oben/unten)
    @State private var rotY: Float = 0.0      // Yaw (links/rechts)

    @State private var velX: Float = 0.0
    @State private var velY: Float = 0.0

    @State private var lastDragX: CGFloat = 0
    @State private var lastDragY: CGFloat = 0

    @State private var inertia = RotationInertiaEngine()

    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: defaultCamera(),
            options: [],
            preferredFramesPerSecond: 60,
            antialiasingMode: .multisampling4X
        )
        .gesture(dragGesture)
        .onAppear {
            loadModel()
            setupInertia()
            inertia.start()
        }
        .onDisappear { inertia.stop() }
    }
}



// MARK: - Gesture + Inertia Engine
private extension Spirit3DMini {

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let deltaX = value.translation.width - lastDragX
                let deltaY = value.translation.height - lastDragY

                lastDragX = value.translation.width
                lastDragY = value.translation.height

                let yaw = Float(deltaX) * 0.01
                let pitch = Float(deltaY) * 1

                rotY += yaw
                rotX -= pitch  // invert: runterziehen = hochschauen

                velY = yaw * 6
                velX = pitch * 6

                applyRotation()
            }
            .onEnded { _ in
                lastDragX = 0
                lastDragY = 0
            }
    }
    func applyRotation() {
        // Pitch clamping
        rotX = max(-0.8, min(0.8, rotX))

        modelNode?.eulerAngles = SCNVector3(rotX, rotY, 0)
    }
    func setupInertia() {
        inertia.onUpdate = {
            guard abs(velX) > 0.0001 || abs(velY) > 0.0001 else { return }

            rotY += velY
            rotX -= velX

            velY *= 0.92
            velX *= 0.92

            applyRotation()
        }
    }

    

    // MARK: Load Model
    func loadModel() {
        scene = SCNScene()
        scene.background.contents = UIColor.clear

        guard let modelScene = SCNScene(named: "\(modelName).usdz"),
              let node = modelScene.rootNode.childNodes.first else {
            print("❌ Modell fehlt:", modelName)
            return
        }

        let (min, _) = node.boundingBox
        node.position = SCNVector3(0, -min.y, 0)
        node.scale = SCNVector3(2, 2, 2)

        scene.rootNode.addChildNode(node)
        modelNode = node

        addLights(to: scene)
    }

    // MARK: Camera
    func defaultCamera() -> SCNNode {
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.position = SCNVector3(0, 1.2, 3.2)
        cam.eulerAngles = SCNVector3(-0.3, 0, 0)
        return cam
    }

    // MARK: Lights
    func addLights(to scene: SCNScene) {
        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = 1600
        key.eulerAngles = SCNVector3(-0.6, 0.2, 0)
        scene.rootNode.addChildNode(key)

        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .directional
        fill.light?.intensity = 700
        fill.eulerAngles = SCNVector3(-0.4, -0.4, 0)
        scene.rootNode.addChildNode(fill)
    }
}


struct SpiritListView: View {

    @State private var spirits: [ModelConfig] = Bundle.main.loadSpiritArray("spirits")

    private let columns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("Spirits")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 10)

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(spirits, id: \.id) { spirit in
                        SpiritCardView(spirit: spirit)
                    }
                }
                .padding(.horizontal, 18)
            }
        }
        .background(
            SpiritGridBackground()
        )
    }
}

#Preview {
    NavigationView {
        SpiritListView()
    }
}
