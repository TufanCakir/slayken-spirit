import SwiftUI
import GameKit

struct HallOfFameView: View {

    @State private var player: GKPlayer?
    @State private var isAuthenticated = false



    var body: some View {
        ZStack {
            SpiritGridBackground()

            

            VStack(spacing: 0) {

                // 🔥 Header bleibt fix oben
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {

                        leaderboardSection(
                            title: "Höchste Stage",
                            leaderboardID: GCHighestStage.leaderboardID
                        )

                        leaderboardSection(
                            title: "Gesammelte Artefakte",
                            leaderboardID: GCArtefacts.leaderboardID
                        )

                        leaderboardSection(
                            title: "Gegner Besiegt",
                            leaderboardID: GCKills.leaderboardID
                        )

                        leaderboardSection(
                            title: "Spielzeit (Minuten)",
                            leaderboardID: GCPlaytime.leaderboardID
                        )

                        leaderboardSection(
                            title: "Abgeschlossene Quests",
                            leaderboardID: GCQuests.leaderboardID
                        )

                        leaderboardSection(
                            title: "Sammlungs-Score",
                            leaderboardID: GCCollection.leaderboardID
                        )

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
        .onAppear {
            GameCenterManager.shared.authenticate { authenticated, player in
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.isAuthenticated = authenticated
                    self.player = player
                }
            }
        }
    }
}


// MARK: - Header Bereich
private extension HallOfFameView {


        var header: some View {
            VStack(spacing: 10) {

                Text("Hall of Fame")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .white.opacity(0.8)],
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
                    .shadow(radius: 8)

                if isAuthenticated {
                    Text("Willkommen, \(player?.displayName ?? "Spieler")")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .transition(.opacity)
                } else {
                    Text("Game Center nicht verbunden")
                        .font(.headline.bold())
                        .foregroundColor(.red.opacity(0.9))
                        .transition(.opacity)
                }

                Button {
                    GameCenterManager.shared.showDashboard()
                } label: {
                    Text("Globales Ranking anzeigen")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                }
                .padding(.top, 4)
            }
        }
    }


private extension HallOfFameView {

    func leaderboardSection(title: String, leaderboardID: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Button {
                GameCenterManager.shared.showLeaderboard(id: leaderboardID)
            } label: {
                HStack {
                    Text("Ansehen")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.2)
                )
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .cyan.opacity(0.25), radius: 10, y: 4)
    }
}
