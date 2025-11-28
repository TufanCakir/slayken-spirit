import SwiftUI

struct QuestView: View {

    @State private var quests: [Quest] = Bundle.main.decode("quests.json")
    @ObservedObject private var questManager = QuestManager.shared
    @State private var selectedQuest: Quest?

    var body: some View {
        ZStack {
            SpiritGridBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {

                    // MARK: Header
                    Text("Quests")
                        .font(
                            .system(size: 40, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                        .padding(.top, 20)

                    // MARK: Quest Cards
                    ForEach(quests) { quest in
                        questCard(quest)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(item: $selectedQuest) { quest in
            QuestRewardDetailView(quest: quest)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

extension QuestView {

    fileprivate func questCard(_ quest: Quest) -> some View {

        let progress = questManager.progress(for: quest)
        let ratio = min(1.0, Double(progress) / Double(quest.target))
        let isDone = progress >= quest.target
        let isClaimed = questManager.completed.contains(quest.id)

        return ZStack {
            // 🔥 Glow-Glass Card Hintergrund
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.07))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.yellow.opacity(0.25), radius: 15, y: 8)

            VStack(alignment: .leading, spacing: 18) {

                // MARK: Header Row
                HStack {
                    Text(QuestManager.shared.localizedTitle(for: quest))
                        .font(
                            .system(size: 22, weight: .bold, design: .rounded)
                        )
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        selectedQuest = quest
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)

                    }
                }

                // MARK: Description
                Text(QuestManager.shared.localizedDescription(for: quest))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.leading)

                // MARK: Progress Bar
                VStack(alignment: .leading, spacing: 6) {

                    ZStack(alignment: .leading) {
                        // Background Bar
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))

                        // Fill Bar
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .yellow, .orange.opacity(0.8),
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geo.size.width * 0.70 * ratio,
                                    alignment: .leading
                                )
                                .animation(
                                    .easeInOut(duration: 0.25),
                                    value: ratio
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 16)

                    Text("\(progress) / \(quest.target)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.7))
                }

                // MARK: Claim Button
                Button {
                    questManager.claim(quest)
                } label: {
                    Text(
                        isClaimed
                            ? "Erhalten"
                            : (isDone
                                ? "Belohnung abholen" : "Noch nicht erfüllt")
                    )
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                isClaimed
                                    ? AnyShapeStyle(Color.green.opacity(0.25))
                                    : (isDone
                                        ? AnyShapeStyle(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        : AnyShapeStyle(
                                            Color.gray.opacity(0.35)
                                        ))
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .disabled(!isDone || isClaimed)

            }
            .padding(20)
        }
    }
}

#Preview {
    QuestView()
}
