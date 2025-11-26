// FÜGE DIESE STRUKTUR IN DEINE DATEI HINZU, WO AUCH GameCenterModalView IST

import SwiftUI
import GameKit

// MARK: - Matchmaker UIKit Wrapper
struct MatchmakerModalView: UIViewControllerRepresentable {
    
    // Konfiguriere die benötigten Parameter für das Matchmaking
    let minPlayers: Int
    let maxPlayers: Int
    
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> GKMatchmakerViewController {
        // Erstellen Sie den Matchmaker Controller mit den benötigten Parametern
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        request.inviteMessage = "Lass uns ein Spiel spielen!" // Optional: Nachricht für Freunde

        let vc = GKMatchmakerViewController(matchRequest: request)!
        vc.matchmakerDelegate = context.coordinator // Delegate setzen
        
        return vc
    }

    func updateUIViewController(_ uiViewController: GKMatchmakerViewController, context: Context) {
        // Keine Aktualisierung notwendig
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // IN MatchManager.swift
    // ... (restlicher Code) ...

    // Daten von einem anderen Spieler empfangen
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        
        // Daten in eine GameAction umwandeln
        guard let action = try? JSONDecoder().decode(GameAction.self, from: data) else {
            print("📥 Konnte empfangene Daten nicht dekodieren.")
            return
        }
        
        // HIER WIRD DIE HP synchronisiert!
        if action.type == .attack {
            // Broadcast the received action so game logic can handle it in the appropriate layer.
            NotificationCenter.default.post(name: .multiplayerDidReceiveAction,
                                            object: nil,
                                            userInfo: ["action": action, "fromPlayer": player])
            print("💥 [MP Attack] Received attack action value=\(action.value) from: \(player.displayName). Forwarded via NotificationCenter.")
        }
        // ... handle andere ActionTypes (.itemCollected, etc.)
    }
    
    // MARK: - Coordinator (Delegate)
    class Coordinator: NSObject, GKMatchmakerViewControllerDelegate {
        var parent: MatchmakerModalView

        init(_ parent: MatchmakerModalView) {
            self.parent = parent
        }
        
        // 1. Match erfolgreich gefunden oder gestartet
            func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
                // WICHTIG: Den Controller entlassen
                parent.dismiss()
                
                // Übergabe an den Manager und Start des Matches
                        MatchManager.shared.startMatch(match)
            
            // HIER STARTET DEIN MULTIPLAYER-SPIEL MIT DEM GEFUNDENEN MATCH-OBJEKT
            print("🎉 Match gefunden! Starte Spiel mit Match: \(match)")
            // Normalerweise übergibst du das 'match'-Objekt hier an deinen Game-State-Manager
        }
        
        // 2. Benutzer hat den Vorgang abgebrochen
        func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
            parent.dismiss()
            print("❌ Matchmaking abgebrochen.")
        }
        
        // 3. Fehler ist aufgetreten
        func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
            parent.dismiss()
            print("❌ Matchmaking fehlgeschlagen mit Fehler: \(error.localizedDescription)")
        }
    }
}

struct MultiplayerView: View {
    
    @ObservedObject var gameCenterManager = GameCenterManager.shared
    @ObservedObject var matchManager = MatchManager.shared // NEU: MatchManager beobachten
    
    @State private var isShowingMatchmaker = false
    @State private var matchmakerParams: (min: Int, max: Int)? = nil

    var body: some View {
        ZStack {
            SpiritGridBackground()

            NavigationView {
                List {
                    // MARK: - Matchmaking starten
                    Section(header: Text("Neues Spiel starten")) {
                        if !matchManager.isMatchActive {
                            // Zeige Matchmaking-Optionen nur, wenn kein Match aktiv ist
                            Button("Real-Time Match (2 Spieler)") {
                                matchmakerParams = (min: 2, max: 2)
                                isShowingMatchmaker = true
                            }.disabled(!gameCenterManager.isAuthenticated)
                            
                            Button("Real-Time Match (4 Spieler)") {
                                matchmakerParams = (min: 2, max: 4)
                                isShowingMatchmaker = true
                            }.disabled(!gameCenterManager.isAuthenticated)
                        } else {
                            // Wenn Match aktiv, zeige Match-Informationen
                            VStack(alignment: .leading) {
                                Text("Match-Status: \(matchManager.matchStateText)")
                                    .foregroundColor(.yellow)

                                // MARK: Spieler-Anzeige
                                HStack {
                                    Text("Teilnehmer:")
                                    ForEach(matchManager.connectedPlayers, id: \.gamePlayerID) { player in
                                        HStack(spacing: 4) {
                                            Image(systemName: "person.fill") // SF Symbol für den Spieler
                                                .foregroundColor(.blue)
                                            Text(player.displayName)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: Leaven-Button
                            Button("❌ Match verlassen") {
                                matchManager.leaveMatch()
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    // ... (Rest der View bleibt gleich) ...
                }
                .navigationTitle("Multiplayer")
                .onAppear { gameCenterManager.authenticate() }
                .sheet(isPresented: $isShowingMatchmaker) {
                    if let params = matchmakerParams {
                        MatchmakerModalView(minPlayers: params.min, maxPlayers: params.max)
                    }
                }
            }
        }
    }
}

#Preview {
    MultiplayerView()
}
