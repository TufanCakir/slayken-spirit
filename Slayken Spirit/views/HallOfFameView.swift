// MARK: - Game Center UIKit Wrapper

import SwiftUI
import GameKit
struct GameCenterModalView: UIViewControllerRepresentable {
    
    // Definiert, ob das Dashboard oder eine spezifische Bestenliste angezeigt werden soll
    enum GameCenterViewType {
        case dashboard
        case leaderboard(id: String)
    }
    
    let viewType: GameCenterViewType
    
    // Environment-Variable, um den Modal-Sheet zu schließen
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let vc = GKGameCenterViewController()
        vc.gameCenterDelegate = context.coordinator // Delegate setzen
        
        switch viewType {
        case .dashboard:
            vc.viewState = .dashboard // Zeigt das Haupt-Dashboard
        case .leaderboard(let id):
            vc.viewState = .leaderboards // Zeigt die Bestenlisten-Seite
            // Optional: Wenn iOS 14/15 unterstützt werden muss, könnte hier
            // der spezifische Leaderboard-Identifier gesetzt werden (GKGameCenterViewController.leaderboardIdentifier = id)
            // Ab iOS 16 öffnet es meist die Liste, von wo aus der Nutzer navigieren kann.
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        // Keine Aktualisierung notwendig
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        var parent: GameCenterModalView

        init(_ parent: GameCenterModalView) {
            self.parent = parent
        }
        
        // Wichtig: Entlässt den View Controller, wenn der Benutzer auf "Fertig" klickt
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            parent.dismiss()
        }
    }
}

struct HallOfFameView: View {
    // GameCenterManager als ObservableObject beobachten
    @ObservedObject var gameCenterManager = GameCenterManager.shared

    struct LeaderboardSelection: Identifiable { let id: String }
    @State private var selectedLeaderboard: LeaderboardSelection? = nil // Optional Identifiable wrapper

    // State-Variablen zum Steuern der Modal-Präsentation
    @State private var showDashboard = false

    var body: some View {
        NavigationView {
            List {
                // MARK: - Authentifizierungsstatus
                Section(header: Text("Game Center Status")) {
                    HStack {
                        Text("Status:")
                        Spacer()
                        Text(gameCenterManager.isAuthenticated ? "✅ Eingeloggt" : "❌ Nicht eingeloggt")
                            .foregroundColor(gameCenterManager.isAuthenticated ? .green : .red)
                    }
                    HStack {
                        Text("Spielername:")
                        Spacer()
                        Text(gameCenterManager.playerName)
                    }
                }
                
                // MARK: - Aktionen
                Section(header: Text("Aktionen")) {
                    // Button zum Login (falls nicht authentifiziert)
                    if !gameCenterManager.isAuthenticated {
                        Button("Game Center Login öffnen") {
                            // Verwendet die bestehende Login-Funktion im Manager
                            gameCenterManager.openGameCenterLogin()
                        }
                    }

                    // Button zum Öffnen des Dashboards (falls authentifiziert)
                    if gameCenterManager.isAuthenticated {
                        Button("Game Center Dashboard anzeigen") {
                            // Löst die Modal-Anzeige aus
                            showDashboard = true
                        }
                    }
                }
                
                // MARK: - Bestenlisten
                Section(header: Text("Bestenlisten")) {
                    // Verwende die neue Hilfs-View, die den State setzt
                    LeaderboardButtonNew(
                        title: "Gesamte Artefakte",
                        id: GCArtefacts.leaderboardID,
                        isAuthenticated: gameCenterManager.isAuthenticated,
                        selected: $selectedLeaderboard // Binding übergeben
                    )
                    LeaderboardButtonNew(
                        title: "Sammel-Score",
                        id: GCCollection.leaderboardID,
                        isAuthenticated: gameCenterManager.isAuthenticated,
                        selected: $selectedLeaderboard
                    )
                    // ... (Füge hier alle weiteren LeaderboardButtonNew Aufrufe ein) ...
                    LeaderboardButtonNew(
                        title: "Höchste Stage",
                        id: GCHighestStage.leaderboardID,
                        isAuthenticated: gameCenterManager.isAuthenticated,
                        selected: $selectedLeaderboard
                    )
                }
            }
            .navigationTitle("Hall of Fame")
            // Game Center Authentifizierung beim Laden der View versuchen
            .onAppear {
                gameCenterManager.authenticate()
            }
            // MARK: - MODALE PRÄSENTATIONEN
            // 1. Dashboard Modal
            .sheet(isPresented: $showDashboard) {
                GameCenterModalView(viewType: .dashboard)
            }
            // 2. Spezifische Bestenliste Modal
            .sheet(item: $selectedLeaderboard) { selection in
                // Nutzt die 'selection' als Item, um den Sheet auszulösen und die ID zu übergeben
                GameCenterModalView(viewType: .leaderboard(id: selection.id))
            }
        }
    }
}

// MARK: - Aktualisierte Hilfs-View für Bestenlisten-Button
// Ersetzt die alte LeaderboardButton
struct LeaderboardButtonNew: View {
    let title: String
    let id: String
    let isAuthenticated: Bool
    @Binding var selected: HallOfFameView.LeaderboardSelection? // Binding auf den State in der Parent View
    
    var body: some View {
        ZStack {
            SpiritGridBackground() // <-- HIER MUSS DIE
        }
        Button(title) {
            selected = HallOfFameView.LeaderboardSelection(id: id) // Setzt die ID und löst das .sheet(item:) in der Parent View aus
        }
        .disabled(!isAuthenticated) // Button deaktivieren, wenn nicht eingeloggt
    }
}

#Preview {
    LeaderboardButtonNew(
        title: "Test",
        id: "spirit_highest_stage",
        isAuthenticated: true,
        selected: .constant(nil)
    )
}
