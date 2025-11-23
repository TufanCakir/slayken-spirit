import SwiftUI

struct UpgradeView: View {

    @EnvironmentObject var coins: CoinManager
    @EnvironmentObject var upgrades: UpgradeManager

    // Lade Hintergrundbild aus JSON
    private let homeBG: String = {
        let spirits = Bundle.main.loadSpiritArray("spirits")
        return spirits.first?.background ?? "sky"
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {

                HomeBackgroundView(imageName: homeBG)
                    .ignoresSafeArea()
                
                VStack(spacing: 22) {

                    // MARK: Tap Damage Upgrade
                    upgradeCard(
                        icon: "hand.tap.fill",
                        title: "Tap Damage",
                        description: "Erhöht den Schaden pro Tap.",
                        value: upgrades.tapDamage,
                        cost: upgrades.tapDamage * 10,
                        action: { upgrades.upgradeTapDamage(cost: upgrades.tapDamage * 10) }
                    )

                    // MARK: Loot Chance Upgrade
                    upgradeCard(
                        icon: "sparkles",
                        title: "Loot Chance",
                        description: "Chance auf Bonusbelohnungen.",
                        value: Int(upgrades.lootChance * 100),
                        cost: 50,
                        action: { upgrades.upgradeLootChance(cost: 50) }
                    )

                    // MARK: Attack Speed Upgrade
                    upgradeCard(
                        icon: "bolt.fill",
                        title: "Attack Speed",
                        description: "Boost für automatische Angriffe.",
                        value: Int(upgrades.speed * 10),
                        cost: Int(upgrades.speed * 100),
                        action: { upgrades.upgradeSpeed(cost: Int(upgrades.speed * 100)) }
                    )

                    Spacer()
                }
                .padding()
                .navigationTitle("Upgrades")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - UPGRADE CARD
    private func upgradeCard(
        icon: String,
        title: String,
        description: String,
        value: Int,
        cost: Int,
        action: @escaping () -> Void
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Label(title, systemImage: icon)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Spacer()

                Text("Lvl \(value)")
                    .font(.headline)
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.4), radius: 4)
            }

            Text(description)
                .foregroundColor(.white.opacity(0.7))
                .font(.subheadline)

            HStack {
                Text("Kosten: \(cost) Coins")
                    .font(.subheadline)
                    .foregroundColor(.yellow)

                Spacer()

                Button {
                    action()
                } label: {
                    Text("Upgrade")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
                                .opacity(CoinManager.shared.coins >= cost ? 1 : 0.3)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.cyan.opacity(CoinManager.shared.coins >= cost ? 0.7 : 0.2), lineWidth: 1.5)
                        )
                }
                .disabled(CoinManager.shared.coins < cost)
            }

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.6), radius: 10)
    }
}
