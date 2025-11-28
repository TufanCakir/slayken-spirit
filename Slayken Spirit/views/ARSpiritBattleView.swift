import RealityKit
import ARKit
import SwiftUI

// MARK: - AR View Wrapper für SwiftUI
struct ARViewRepresentable: UIViewRepresentable {
    
    // Die ModelConfig vom GameController wird benötigt,
    // um das 3D-Modell im AR-Modus zu laden.
    @EnvironmentObject private var game: SpiritGameController
    
    func makeUIView(context: Context) -> ARView {
        // Erstellen und Konfigurieren der ARView
        let arView = ARView(frame: .zero)
        
        // Führen Sie die Standard-AR-Session-Konfiguration aus
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical] // Optional: Ebenenerkennung aktivieren
        arView.session.run(config)
        
        // Kontext-Koordinator einrichten, um Updates vom GameController zu empfangen
        context.coordinator.arView = arView
        
        // Fügen Sie einen Gesten-Recognizer hinzu, um das 3D-Modell zu platzieren
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Hier können Sie auf Änderungen im GameController reagieren
        // z.B. das Spirit-Modell aktualisieren oder entfernen
        context.coordinator.config = game.current
    }
    
    // MARK: - Coordinator
    
    // Der Coordinator wird benötigt, um UIKit-Aktionen (wie Taps)
    // zu verarbeiten und UI-Updates in SwiftUI zurückzugeben (optional),
    // sowie, um RealityKit-spezifische Logik zu kapseln.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewRepresentable
        weak var arView: ARView?
        var entity: Entity? // Die aktuell platzierte Entität (das Spirit-Modell)
        var config: ModelConfig? // Aktuelle Konfiguration
        
        init(parent: ARViewRepresentable) {
            self.parent = parent
        }
        
        // Wird bei einer Tap-Geste aufgerufen
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            // 1. Treffer-Erkennung (Raycasting)
            let location = recognizer.location(in: arView)
            
            // Finde eine Trefferfläche (z.B. eine erkannte Ebene)
            let hits = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)
            
            // Wenn eine Ebene getroffen wurde
            if let firstHit = hits.first {
                
                // 2. Anker erstellen und hinzufügen
                let anchor = AnchorEntity(raycastResult: firstHit)
                
                // 3. 3D-Modell (Entity) erstellen
                // **HINWEIS:** Hier müssen Sie Ihr 3D-Modell laden.
                // Ersetzen Sie "SpiritModel.usdz" durch den tatsächlichen Namen Ihres Modells,
                // das sich in Ihrem Xcode-Projekt befinden muss (z.B. in einem .rcproject).
                
                guard let modelConfig = config else { return }
                
                // Das ist ein Platzhalter. Im echten Projekt müssten Sie Ihr Modell
                // basierend auf der Konfiguration laden und anpassen.
                // Zum Beispiel:
                // let spiritEntity = try? Entity.load(named: modelConfig.modelName)
                
                // Verwenden wir eine einfache Box als Platzhalter, falls kein 3D-Modell vorhanden ist
                let boxMesh = MeshResource.generateBox(size: 0.1) // 10 cm Würfel
                let material = SimpleMaterial(color: UIColor(named: modelConfig.gridColor) ?? .cyan, isMetallic: false)
                let spiritEntity = ModelEntity(mesh: boxMesh, materials: [material])
                
                // Optional: Füge eine Collider-Komponente hinzu, damit es auf Taps reagiert
                spiritEntity.generateCollisionShapes(recursive: true)
                
                // Entferne das alte Modell und platziere das neue
                entity?.removeFromParent()
                entity = spiritEntity
                
                anchor.addChild(spiritEntity)
                arView.scene.addAnchor(anchor)
                
                // Optional: Ausrichtung an der Kamera (Blickrichtung)
                if arView.session.currentFrame?.camera.transform != nil {
                    let matrix = simd_float4x4(
                        [1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z, 1]
                    )
                    
                    // Drehe die Entität so, dass sie von der Kamera weg zeigt
                    spiritEntity.transform.rotation = simd_quatf(matrix)
                }
                
                // Hier könnten Sie auch den game.tapAttack() Call auslösen,
                // wenn der Tap auf das platzierte 3D-Modell geht.
            }
        }
    }
}

// HINWEIS: Sie benötigen auch eine Erweiterung für UIColor/Color, um Hex-Farben zu verarbeiten,
// da 'Color(hex: ...)' im Originalcode verwendet wird.

