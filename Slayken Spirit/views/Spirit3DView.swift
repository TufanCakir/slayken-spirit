import SwiftUI
import SceneKit

struct Spirit3DView: View {

    let modelName: String
    let rotation: Float
    let scale: Float

    var body: some View {
        SceneView(
            scene: loadScene(),
            pointOfView: defaultCamera(),
            options: [.allowsCameraControl],
            preferredFramesPerSecond: 60,
            antialiasingMode: .multisampling4X,
            delegate: nil
        )
        .scaleEffect(CGFloat(scale))
        .rotation3DEffect(
            Angle(radians: Double(rotation)),
            axis: (x: 0, y: 1, z: 0)
        )
        .background(Color.clear)
    }
}

extension Spirit3DView {

    // MARK: - Load Scene
    func loadScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        // 🔹 Add the Model
        if let modelScene = SCNScene(named: "\(modelName).usdz"),
           let modelNode = modelScene.rootNode.childNodes.first {

            // Fix: place model on ground
            let (min, max) = modelNode.boundingBox
            let height = max.y - min.y
            modelNode.position = SCNVector3(0, -min.y, 0)

            // Scale controlled outside via SwiftUI's scaleEffect
            modelNode.scale = SCNVector3(1, 1, 1)

            scene.rootNode.addChildNode(modelNode)
        } else {
            print("❌ Modell nicht gefunden:", modelName)
        }

        // MARK: Lights
        addLights(to: scene)

        return scene
    }

    // MARK: - Studio Camera
    func defaultCamera() -> SCNNode {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 1.2, 3.0)
        cameraNode.eulerAngles = SCNVector3(-0.25, 0, 0) // leichte Neigung
        return cameraNode
    }

    // MARK: - Three Point Lighting Setup
    func addLights(to scene: SCNScene) {

        // 1️⃣ Key Light (Hauptlicht)
        let key = SCNLight()
        key.type = .directional
        key.intensity = 1800
        key.color = UIColor.white
        let keyNode = SCNNode()
        keyNode.light = key
        keyNode.eulerAngles = SCNVector3(-0.6, 0.4, 0) // schräg vorne
        scene.rootNode.addChildNode(keyNode)

        // 2️⃣ Fill Light (füllt Schatten weich)
        let fill = SCNLight()
        fill.type = .directional
        fill.intensity = 900
        fill.color = UIColor(white: 0.8, alpha: 1)
        let fillNode = SCNNode()
        fillNode.light = fill
        fillNode.eulerAngles = SCNVector3(-0.4, -0.6, 0)
        scene.rootNode.addChildNode(fillNode)

        // 3️⃣ Back Light (Kantenlicht)
        let rim = SCNLight()
        rim.type = .directional
        rim.intensity = 1200
        rim.color = UIColor.white
        let rimNode = SCNNode()
        rimNode.light = rim
        rimNode.eulerAngles = SCNVector3(0.8, 0.5, 0)
        scene.rootNode.addChildNode(rimNode)

        // Soft ambient light
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 300
        ambient.color = UIColor(white: 1.0, alpha: 1)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)
    }
}
