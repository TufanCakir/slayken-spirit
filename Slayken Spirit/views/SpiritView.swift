import SwiftUI
import RealityKit
internal import GameKit

struct SpiritView: View {
    
    @ObservedObject var matchManager = MatchManager.shared

    let config: ModelConfig
    
    // Eindeutige ID für den Boss-Anchor, um ihn später in 'update' wiederzufinden
    private let bossAnchorName = "BossSpiritAnchor"

    var body: some View {
        RealityView { content in
            do {

                // -------------------------------------------------------
                // MARK: BOSS/HAUPTMODELL LADEN (INIT)
                // -------------------------------------------------------
                let model = try await Entity(named: config.modelName)
                model.scale = SIMD3<Float>(config.scale) * 1.5
                let slightTurn = simd_quatf(angle: -.pi/15, axis: [0, 5, 0])

                // Pivot auf Boden setzen (Einmalige Korrektur)
                let bounds = model.visualBounds(relativeTo: model)
                model.position.y -= bounds.min.y

                // Container (Eltern-Entity) für Rotation und Position
                let pivotParent = Entity()
                pivotParent.addChild(model)
                pivotParent.position = SIMD3<Float>(config.position)
                pivotParent.position.z += 1.0
                
                // Facing aus JSON (Left/Right)
                if let facing = config.facing?.lowercased() {
                    switch facing {
                    case "left":
                        pivotParent.orientation = simd_quatf(angle: .pi/2, axis: [0,1,0])
                    case "right":
                        pivotParent.orientation = simd_quatf(angle: -.pi/2, axis: [0,1,0])
                    default: break
                    }
                }

                // Anchor fürs Boss-Modell
                let modelAnchor = AnchorEntity(world: .zero)
                modelAnchor.name = bossAnchorName // WICHTIG: Anchor benennen
                modelAnchor.addChild(pivotParent)
                content.add(modelAnchor)
                
                
                // -------------------------------------------------------
                // MARK: CAMERA & LIGHT (Bestehende Logik)
                // -------------------------------------------------------
                let cam = PerspectiveCamera()
                let camPos = SIMD3<Float>(config.camera.position)
                let camLook = SIMD3<Float>(config.camera.lookAt)

                cam.position = camPos
                cam.look(at: camLook, from: camPos, relativeTo: nil)

                let camAnchor = AnchorEntity(world: .zero)
                camAnchor.addChild(cam)
                content.add(camAnchor)

                // MODEL FACING CAMERA (Wiederhergestellt)
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
                
                // Die finale Orientierung des Bosses setzen
                pivotParent.orientation = lookRotation * slightTurn

                // LIGHT (von vorne)
                let light = PointLight()
                // light.light.intensity = config.light.intensity // Anpassen falls nötig
                // light.position = SIMD3<Float>(config.light.position) // Anpassen falls nötig
                camAnchor.addChild(light)

            } catch {
                print("❌ RealityKit Fehler beim Laden des Bosses:", error.localizedDescription)
            }
        } update: { content in // MARK: UPDATE CLOSURE (Multiplayer Logik)
            
            guard let bossAnchor = content.entities.first(where: { $0.name == self.bossAnchorName }) as? AnchorEntity else {
                return
            }
            
            // Wenn kein Match aktiv, alle Spieler-Avatare entfernen und abbrechen.
            if !self.matchManager.isMatchActive {
                // Filtern nach Entities, deren Namen mit "player_" beginnen
                bossAnchor.children.filter { $0.name.starts(with: "player_") }.forEach { $0.removeFromParent() }
                return
            }

            let connectedPlayers = self.matchManager.connectedPlayers
            
            // --- 1. Neue Spieler hinzufügen und existierende positionieren ---
            for (index, player) in connectedPlayers.enumerated() {
                let entityName = "player_\(player.playerID)"
                
                // Positionierungs-Logik: Kreisförmig um den Boss
                let angle = Float(index) * 2 * .pi / Float(connectedPlayers.count)
                let radius: Float = 0.8 // Radius um den Boss
                let playerScale: Float = 0.3 // Kleinere Skalierung für Spieler-Spirits
                
                let targetX = radius * cos(angle)
                let targetZ = radius * sin(angle)
                // Spieler auf Bodenniveau (0.0)
                let targetPosition = SIMD3<Float>(targetX, 0.0, targetZ)
                
                // Prüfen, ob Entity bereits existiert
                if let existingPlayerEntity = bossAnchor.findEntity(named: entityName) {
                    // Entity existiert: Position aktualisieren (optional mit Animation)
                    existingPlayerEntity.transform.translation = targetPosition
                } else {
                    // Entity ist NEU: Laden und hinzufügen
                    Task {
                        do {
                            // !!! VERWENDE DEIN BOSS MODELL ALS SPIELER-AVATAR !!!
                            let playerModelName = self.config.modelName // Nutze das aktuelle Boss-Modell
                            let newPlayerEntity = try await Entity(named: playerModelName)
                            
                            newPlayerEntity.name = entityName
                            newPlayerEntity.scale = SIMD3<Float>(playerScale, playerScale, playerScale)
                            
                            // Verschieben des Modells auf den Boden (falls es auch einen Pivot-Fehler hat)
                            let playerBounds = newPlayerEntity.visualBounds(relativeTo: newPlayerEntity)
                            newPlayerEntity.position.y -= playerBounds.min.y
                            
                            newPlayerEntity.transform.translation += targetPosition
                            
                            bossAnchor.addChild(newPlayerEntity)
                            
                            print("✅ Spieler Spirit \(player.displayName) geladen: \(playerModelName)")

                        } catch {
                            print("❌ Fehler beim Laden des Spieler-Spirits: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            // --- 2. Spirits von getrennten Spielern entfernen ---
            
            let connectedIDs = Set(connectedPlayers.map { "player_\($0.playerID)" })
            
            // Verwende findEntity(named:) ist sicherer, aber children.filter ist für dieses Szenario effizienter
            bossAnchor.children.filter { $0.name.starts(with: "player_") }.forEach { entity in                if !connectedIDs.contains(entity.name) {
                    entity.removeFromParent()
                    print("🗑️ Spirit für \(entity.name) entfernt (Spieler getrennt).")
                }
            }
        }
        .ignoresSafeArea()
    }
}

