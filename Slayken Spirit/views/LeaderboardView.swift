import SwiftUI
internal import GameKit
internal import Combine

struct LeaderboardView: View {

    @StateObject private var vm = LeaderboardViewModel()

    var body: some View {
        ZStack {
            SpiritGridBackground()

            VStack(spacing: 16) {

                // MARK: - HEADER
                VStack(spacing: 4) {
                    Text("RANGLISTEN")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Deine persönlichen Rekorde")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.top, 20)

                // MARK: - CONTENT
                if vm.isLoading {
                    ProgressView()
                        .tint(.cyan)
                        .scaleEffect(1.5)
                        .padding(.top, 40)
                } else {
                    leaderboardGrid
                }

                Spacer()
            }
            .padding(.horizontal)
        }
        .task {
            await vm.loadScores()
        }
    }

    // MARK: - GRID
    private var leaderboardGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 14
        ) {
            ForEach(vm.entries) { entry in
                VStack(spacing: 8) {

                    Text(entry.title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(entry.score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.cyan)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .cyan.opacity(0.15), radius: 10)
                )
            }
        }
    }
}

@MainActor
final class LeaderboardViewModel: ObservableObject {

    struct LeaderboardEntry: Identifiable {
        let id = UUID()
        let title: String
        var score: Int
        let leaderboardID: String
    }

    @Published var isLoading = true
    @Published var entries: [LeaderboardEntry] = []

    init() {
        entries = [
            .init(title: "Kills",            score: 0, leaderboardID: GCKills.leaderboardID),
            .init(title: "Artefakte",        score: 0, leaderboardID: GCArtefacts.leaderboardID),
            .init(title: "Quests",           score: 0, leaderboardID: GCQuests.leaderboardID),
            .init(title: "Sammlung",         score: 0, leaderboardID: GCCollection.leaderboardID),
            .init(title: "Spielzeit",        score: 0, leaderboardID: GCPlaytime.leaderboardID),
            .init(title: "Höchste Stage",    score: 0, leaderboardID: GCHighestStage.leaderboardID)
        ]
    }

    // MARK: - Lade Scores
    func loadScores() async {
        isLoading = true
        var updated = entries

        for (index, e) in updated.enumerated() {
            do {
                let leaderboard = try await GKLeaderboard.loadLeaderboards(IDs: [e.leaderboardID]).first

                guard let leaderboard else {
                    print("⚠️ Kein Leaderboard für \(e.title)")
                    continue
                }

                // Lokal (Spieler)
                let (local, _, _) = try await leaderboard.loadEntries(
                    for: .global,
                    timeScope: .allTime,
                    range: NSRange(location: 1, length: 1)
                )

                if let localScore = local?.score {
                    updated[index].score = localScore
                }

            } catch {
                print("❌ Fehler für \(e.title): \(error.localizedDescription)")
            }
        }

        withAnimation {
            self.entries = updated
            self.isLoading = false
        }
    }
}

#Preview {
    LeaderboardView()
        .preferredColorScheme(.dark)
}
