import SwiftUI
internal import GameKit

struct MultiplayerView: View {
    
    @ObservedObject var gameCenterManager = GameCenterManager.shared
    @ObservedObject var matchManager = MatchManager.shared
    
    @State private var isShowingMatchmaker = false
    @State private var matchmakerParams: (min: Int, max: Int)? = nil
    @State private var multiplayerEvents: [MultiplayerEvent] = []
    @State private var selectedEvent: MultiplayerEvent?

    // Value-based navigation route (hashable via event ID only)
    private enum Route: Hashable, Identifiable {
        case bossList(eventID: String)
        
        var id: String {
            switch self {
            case .bossList(let eventID):
                return "bossList_\(eventID)"
            }
        }
    }
    @State private var route: Route?
    @State private var selectedBosses: [MultiplayerBoss] = []
    
    @State private var multiplayerBosses: [MultiplayerBoss] = []
    
    init() {
        if let loaded: [MultiplayerEvent] = try? Bundle.main.decodeSafe("multiplayer.json") {
            _multiplayerEvents = State(initialValue: loaded)
        }
    }
    
    var body: some View {
        ZStack {
            SpiritGridBackground(glowColor: Color(hex: selectedEvent?.gridColor ?? "#00BFFF"))

            
            NavigationStack {
                ZStack {
                    SpiritGridBackground(glowColor: Color(hex: selectedEvent?.gridColor ?? "#00BFFF"))

                    // TITLE
                    Text("Wähle deinen Spielmodus")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 40)
                    
                    // --- MODUS-KARUSSELL ---
                    TabView {
                        modeCard(
                            title: "1v1 Echtzeit",
                            icon: "bolt.fill",
                            iconColor: .yellow,
                            gradient: [.cyan, .blue, .black],
                            players: (2, 2)
                        )
                        
                        modeCard(
                            title: "2-4 Spieler Match",
                            icon: "person.3.fill",
                            iconColor: .green,
                            gradient: [.blue, .black],
                            players: (2, 4)
                        )
                        
                        modeCard(
                            title: "Koop Raid",
                            icon: "flame.fill",
                            iconColor: .blue,
                            gradient: [.red, .red, .black],
                            players: nil,
                            disabled: true
                        )
                        
                        modeCard(
                            title: "Training",
                            icon: "figure.run.circle.fill",
                            iconColor: .black,
                            gradient: [.gray, .gray, .black],
                            players: nil,
                            disabled: true
                        )
                    }
                    .tabViewStyle(.page)
                    .frame(height: 200)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 300)
                    
                    // Hidden value-based navigation trigger
                    NavigationLink(value: route) { EmptyView() }
                        .hidden()
                    
                    Spacer()
                    
                    // --- MATCH STATUS ---
                    if matchManager.isMatchActive {
                        VStack(spacing: 12) {
                            
                            Text("🟢 \(matchManager.matchStateText)")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text("Teilnehmer:")
                                    .foregroundColor(.white)
                                    .bold()
                                
                                ForEach(matchManager.connectedPlayers, id: \.gamePlayerID) { player in
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.cyan)
                                        Text(player.displayName)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
                            Button("❌ Match verlassen") {
                                matchManager.leaveMatch()
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.3))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .bossList(let eventID):
                        if let event = multiplayerEvents.first(where: { $0.id == eventID }) {
                            MultiplayerBossListView(event: event)
                        } else {
                            Text("Event nicht gefunden").foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { matchManager.isMatchActive },
                set: { _ in }
            )) {
                SpiritGameView().environmentObject(SpiritGameController())
            }
        }
    }
    
// MARK: - Einzelne Modus-Karte
    @ViewBuilder
    private func modeCard(
        title: String,
        icon: String,
        iconColor: Color,
        gradient: [Color],
        players: (Int, Int)?,
        disabled: Bool = false
    ) -> some View {
        Button {
            if let players = players, !disabled {
                let events = filteredEvents(for: players)
                if let first = events.first {
                    selectedEvent = first
                    route = .bossList(eventID: first.id)
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 10)
                
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(iconColor)
                    
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 180)
        .disabled(disabled || !gameCenterManager.isAuthenticated)
    }
    
    private func filteredEvents(for players: (Int, Int)?) -> [MultiplayerEvent] {
        guard let players = players else { return [] }
        
        switch players {
        case (2, 2):
            return multiplayerEvents.filter { $0.category == .trial || $0.category == .special }
        case (2, 4):
            return multiplayerEvents.filter { $0.category == .raid }
        default:
            return []
        }
    }
}

struct MultiplayerBossListView: View {
    let event: MultiplayerEvent
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List(event.bosses.indices, id: \.self) { index in
            let boss = event.bosses[index]
            Button {
                SpiritGameController().startMultiplayer(event) // Nutze den vollständigen Event
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.name)
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("Phase \(index + 1):")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)

                    Text("• Models: \(boss.modelNames.joined(separator: ", "))")
                        .foregroundColor(.cyan)

                    Text("HP: \(boss.hp.value(at: 0))")
                        .foregroundColor(.white)

                    Text("Coins: \(boss.coins.value(at: 0))")
                        .foregroundColor(.yellow)

                    Text("Crystals: \(boss.crystals.value(at: 0))")
                        .foregroundColor(.mint)

                    Text("EXP: \(boss.exp.value(at: 0))")
                        .foregroundColor(.orange)
                }
                .padding(.vertical, 8)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .navigationTitle("Wähle einen Boss")
    }
}



#Preview {
    MultiplayerView()
}
