import SwiftUI

struct HallOfFameView: View {

    private let leaderboards: [LeaderboardEntry] = [
        .init(
            id: "spirit_multiplayer_wins",
            title: "Multiplayer-Siege",
            color: .cyan,
            icon: "person.2.wave.2.fill"
        ),
        .init(
            id: "spirit_total_kills",
            title: "Besiegte Gegner",
            color: .red,
            icon: "flame.fill"
        ),
        .init(
            id: "spirit_total_artefacts",
            title: "Artefakte gesammelt",
            color: .mint,
            icon: "sparkles"
        ),
        .init(
            id: "spirit_quests_completed",
            title: "Abgeschlossene Quests",
            color: .orange,
            icon: "checkmark.seal.fill"
        ),
        .init(
            id: "spirit_collection_score",
            title: "Sammlungswert",
            color: .yellow,
            icon: "star.circle.fill"
        ),
        .init(
            id: "spirit_playtime_minutes",
            title: "Spielzeit (Minuten)",
            color: .gray,
            icon: "clock.fill"
        ),
        .init(
            id: "spirit_highest_stage",
            title: "Höchste Stage",
            color: .blue,
            icon: "arrow.up.right.square.fill"
        )
    ]

    @ObservedObject private var gc = GameCenterManager.shared

    var body: some View {
        ZStack {
            SpiritGridBackground(glowColor: .blue)

            ScrollView {
                VStack(spacing: 24) {
                    Text("🏆 Hall of Fame")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                        .padding(.top)

                    ForEach(leaderboards) { entry in
                        Button {
                            gc.showLeaderboard(id: entry.id)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: entry.icon)
                                    .font(.system(size: 32))
                                    .foregroundColor(entry.color)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Tippe zum Öffnen")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    HallOfFameView()
}
