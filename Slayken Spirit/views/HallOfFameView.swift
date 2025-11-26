import SwiftUI
import GameKit

struct HallOfFameView: View {

    @ObservedObject var gc = GameCenterManager.shared

    var body: some View {
        ZStack {
            SpiritGridBackground()

            VStack(spacing: 0) {

                header
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {

                        leaderboardSection(title: "Höchste Stage",
                                           leaderboardID: GCHighestStage.leaderboardID)

                        leaderboardSection(title: "Gesammelte Artefakte",
                                           leaderboardID: GCArtefacts.leaderboardID)

                        leaderboardSection(title: "Gegner Besiegt",
                                           leaderboardID: GCKills.leaderboardID)

                        leaderboardSection(title: "Spielzeit (Minuten)",
                                           leaderboardID: GCPlaytime.leaderboardID)

                        leaderboardSection(title: "Abgeschlossene Quests",
                                           leaderboardID: GCQuests.leaderboardID)

                        leaderboardSection(title: "Sammlungs-Score",
                                           leaderboardID: GCCollection.leaderboardID)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
    }
}



// MARK: - Header Bereich
private extension HallOfFameView {
    var header: some View {
        VStack(spacing: 12) {

            VStack(spacing: 4) {
                Text("Hall of Fame")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .cyan.opacity(0.9)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .cyan.opacity(0.4), radius: 8)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 15, y: 8)

            // AUTH CHECK
            if gc.isAuthenticated {
                Text("Willkommen, \(gc.playerName)")
                    .font(.headline)
                    .foregroundColor(.green.opacity(0.9))
            } else {
                Text("Nicht eingeloggt")
                    .font(.headline.bold())
                    .foregroundColor(.red.opacity(0.9))
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
            .padding(.top, 6)
        }
    }
}




private extension HallOfFameView {

    func leaderboardSection(title: String, leaderboardID: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white.opacity(0.95))

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
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1.2)
                )
                .shadow(color: .cyan.opacity(0.2), radius: 12, y: 6)
            }
        }
        .padding(20)
        .background(
            .ultraThinMaterial.blendMode(.overlay)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.06), .cyan.opacity(0.15)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.2
                )
        )
    }
}

#Preview {
    HallOfFameView()
}
