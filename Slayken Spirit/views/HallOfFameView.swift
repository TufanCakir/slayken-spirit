// MARK: - Game Center UIKit Wrapper

import SwiftUI
internal import GameKit

struct GameCenterModalView: UIViewControllerRepresentable {
    
    enum GameCenterViewType {
        case dashboard
        case leaderboard(id: String)
    }
    
    let viewType: GameCenterViewType
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let vc = GKGameCenterViewController()
        vc.gameCenterDelegate = context.coordinator
        
        switch viewType {
        case .dashboard:
            vc.viewState = .dashboard
        case .leaderboard(let id):
            vc.viewState = .leaderboards
            vc.leaderboardIdentifier = id
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        var parent: GameCenterModalView

        init(_ parent: GameCenterModalView) {
            self.parent = parent
        }
        
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            parent.dismiss()
        }
    }
}


// MARK: - Hall Of Fame View

struct HallOfFameView: View {
    @ObservedObject var gameCenterManager = GameCenterManager.shared
    
    struct LeaderboardSelection: Identifiable { let id: String }
    @State private var selectedLeaderboard: LeaderboardSelection? = nil
    @State private var showDashboard = false
    
    var body: some View {
        ZStack {
           
            
            NavigationView {
                List {
                    // MARK: Status
                    Section(header: Text("Game Center Status").foregroundColor(.white)) {
                        HStack {
                            Text("Status:").foregroundColor(.white)
                            Spacer()
                            Text(gameCenterManager.isAuthenticated ? "✅ Eingeloggt" : "❌ Nicht eingeloggt")
                                .foregroundColor(gameCenterManager.isAuthenticated ? .green : .red)
                        }
                        HStack {
                            Text("Spielername:").foregroundColor(.white)
                            Spacer()
                            Text(gameCenterManager.playerName).foregroundColor(.white)
                        }
                    }
                    
                    // MARK: Aktionen
                    Section(header: Text("Aktionen").foregroundColor(.white)) {
                        if !gameCenterManager.isAuthenticated {
                            Button("Game Center Login öffnen") {
                                gameCenterManager.openGameCenterLogin()
                            }
                            .foregroundColor(.white)
                        }
                        
                        if gameCenterManager.isAuthenticated {
                            Button("Game Center Dashboard anzeigen") {
                                showDashboard = true
                            }
                            .foregroundColor(.cyan)
                        }
                    }
                    
                    // MARK: Bestenlisten
                    Section(header: Text("Bestenlisten").foregroundColor(.white)) {
                        LeaderboardButtonNew(
                            title: "Gesamte Artefakte",
                            id: GCArtefacts.leaderboardID,
                            isAuthenticated: gameCenterManager.isAuthenticated,
                            selected: $selectedLeaderboard
                        )
                        LeaderboardButtonNew(
                            title: "Sammel-Score",
                            id: GCCollection.leaderboardID,
                            isAuthenticated: gameCenterManager.isAuthenticated,
                            selected: $selectedLeaderboard
                        )
                        LeaderboardButtonNew(
                            title: "Höchste Stage",
                            id: GCHighestStage.leaderboardID,
                            isAuthenticated: gameCenterManager.isAuthenticated,
                            selected: $selectedLeaderboard
                        )
                        LeaderboardButtonNew(
                            title: "Multiplayer-Siege",
                            id: GCMPWins.leaderboardID,
                            isAuthenticated: gameCenterManager.isAuthenticated,
                            selected: $selectedLeaderboard
                        )
                    }
                    .background(.ultraThinMaterial)
                }
                .scrollContentBackground(.hidden)
                .background(SpiritGridBackground())
                .navigationTitle("Hall of Fame")
                .onAppear { gameCenterManager.authenticate() }
                .sheet(isPresented: $showDashboard) {
                    GameCenterModalView(viewType: .dashboard)
                }
                .sheet(item: $selectedLeaderboard) { selection in
                    GameCenterModalView(viewType: .leaderboard(id: selection.id))
                }
            }
        }
    }
}


// MARK: - LeaderboardButtonNew

struct LeaderboardButtonNew: View {
    let title: String
    let id: String
    let isAuthenticated: Bool
    @Binding var selected: HallOfFameView.LeaderboardSelection?

    var body: some View {
        Button {
            selected = .init(id: id)
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.cyan)
            }
            .padding(6)
        }
        .disabled(!isAuthenticated)
        .listRowBackground(Color.black.opacity(0.4))
    }
}

#Preview {
    HallOfFameView()
        .preferredColorScheme(.dark)
}
