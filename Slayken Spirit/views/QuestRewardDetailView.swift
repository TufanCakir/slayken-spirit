import SwiftUI

struct QuestRewardDetailView: View {
    let quest: Quest

    var body: some View {
        VStack(spacing: 24) {

            Text("Belohnungen")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 16)

            VStack(spacing: 14) {

                if quest.reward.coins > 0 {
                    rewardRow(
                        "Coins",
                        value: quest.reward.coins,
                        icon: "dollarsign.circle.fill"
                    )
                }

                if quest.reward.crystals > 0 {
                    rewardRow(
                        "Crystals",
                        value: quest.reward.crystals,
                        icon: "diamond.fill"
                    )
                }

                if quest.reward.exp > 0 {
                    rewardRow("EXP", value: quest.reward.exp, icon: "bolt.fill")
                }

                if let art = quest.reward.artefact {
                    rewardRow(art, value: nil, icon: "sparkles")
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.black, .blue.opacity(0.4), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    @ViewBuilder
    func rewardRow(_ text: String, value: Int?, icon: String) -> some View {
        HStack(spacing: 12) {

            Image(systemName: icon)
                .foregroundColor(.cyan)
                .font(.title3)

            Text(value != nil ? "\(text): \(value!)" : text)
                .foregroundColor(.white)
                .font(.headline)

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
