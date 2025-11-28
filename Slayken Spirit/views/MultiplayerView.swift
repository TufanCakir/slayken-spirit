// MultiplayerView.swift
import SwiftUI
internal import GameKit

private enum Route: Hashable, Identifiable {
    case bossList(eventID: String)
    case game
    var id: String {
        switch self {
        case .bossList(let id): return "bossList_\(id)"
        case .game: return "game"
        }
    }
}

struct MultiplayerView: View {
    @ObservedObject var gameCenterManager = GameCenterManager.shared
    @ObservedObject var matchManager = MatchManager.shared
    @StateObject private var game = SpiritGameController()
    
    @State private var multiplayerEvents: [MultiplayerEvent] = []
    @State private var selectedEvent: MultiplayerEvent?
    @State private var navPath = NavigationPath()
    
    init() {
        if let loaded: [MultiplayerEvent] = try? Bundle.main.decodeSafe("multiplayer.json") {
            _multiplayerEvents = State(initialValue: loaded)
        }
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                SpiritGridBackground(glowColor: Color(hex: selectedEvent?.gridColor ?? "#00BFFF"))
                
                VStack(spacing: 20) {
                    Text("Wähle deinen Spielmodus")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 40)
                    
                    TabView {
                        modeCard(title: "1v1 Echtzeit", icon: "bolt.fill", iconColor: .yellow, gradient: [.cyan, .blue, .black], players: (2, 2))
                        modeCard(title: "2-4 Spieler Match", icon: "person.3.fill", iconColor: .green, gradient: [.blue, .black], players: (2, 4))
                        modeCard(title: "Koop Raid", icon: "flame.fill", iconColor: .blue, gradient: [.red, .red, .black], players: nil, disabled: true)
                        modeCard(title: "Training", icon: "figure.run.circle.fill", iconColor: .black, gradient: [.gray, .gray, .black], players: nil, disabled: true)
                    }
                    .tabViewStyle(.page)
                    .frame(height: 200)
                    .padding(.horizontal, 10)
                    
                    MultiplayerChatOverlay()
                        .padding(.bottom, 0)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .background(.black)
                    
                    Spacer()
                    
                    if matchManager.isMatchActive {
                        activeMatchInfo
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .bossList(let eventID):
                        if let event = multiplayerEvents.first(where: { $0.id == eventID }) {
                            MultiplayerBossListView(event: event, navPath: $navPath)
                                .environmentObject(game)
                                .environmentObject(matchManager)
                        } else {
                            Text("Event nicht gefunden").foregroundStyle(.red)
                        }
                    case .game:
                        if game.isInMultiplayerMode {
                            SpiritGameView()
                                .environmentObject(game)
                                .environmentObject(matchManager)
                        } else {
                            ProgressView("Lade Spiel ...").foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .multiplayerDidFinish)) { _ in
            DispatchQueue.main.async {
                navPath = NavigationPath()
            }
        }
    }

    private var activeMatchInfo: some View {
        VStack(spacing: 12) {
            Text("🟢 \(matchManager.matchStateText)")
                .font(.headline)
                .foregroundColor(.green)

            VStack(alignment: .leading) {
                Text("Teilnehmer:")
                    .foregroundColor(.white)
                    .bold()

                ForEach(matchManager.connectedPlayers, id: \ .gamePlayerID) { player in
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
                    navPath.append(Route.bossList(eventID: first.id))
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
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

    private func filteredEvents(for players: (Int, Int)) -> [MultiplayerEvent] {
        switch players {
        case (2, 2): return multiplayerEvents.filter { $0.category == .trial || $0.category == .special }
        case (2, 4): return multiplayerEvents.filter { $0.category == .raid }
        default: return []
        }
    }
}

struct MultiplayerBossListView: View {
    let event: MultiplayerEvent
    @Binding var navPath: NavigationPath
    @EnvironmentObject var game: SpiritGameController
    @EnvironmentObject var matchManager: MatchManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(event.bosses.indices, id: \.self) { index in
                    let boss = event.bosses[index]
                    Button {
                        print("🔥 Start Multiplayer für: \(event.name)")
                        game.startMultiplayer(event)
                        navPath.append(Route.game)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(event.name).font(.title3.bold()).foregroundColor(.white)
                            Text(event.description).font(.subheadline).foregroundColor(.white.opacity(0.8))
                            Text("Phase \(index + 1):").font(.subheadline.bold()).foregroundColor(.orange)
                            Text("• Models: \(boss.modelNames.joined(separator: ", "))").foregroundColor(.cyan)
                            Text("HP: \(boss.hp.value(at: 0))").foregroundColor(.white)
                            Text("Coins: \(boss.coins.value(at: 0))").foregroundColor(.yellow)
                            Text("Crystals: \(boss.crystals.value(at: 0))").foregroundColor(.mint)
                            Text("EXP: \(boss.exp.value(at: 0))").foregroundColor(.orange)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(14)
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
        .navigationTitle("Wähle einen Boss")
    }
}

#Preview {
    MultiplayerView()
}
