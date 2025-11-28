import SwiftUI

struct HeaderView: View {

    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var crystalManager: CrystalManager
    @EnvironmentObject var accountManager: AccountLevelManager
    @EnvironmentObject var artefacts: ArtefactInventoryManager

    @State private var icons: HUDIconSet = Bundle.main.decode("hudIcons.json")
    @State private var glow = false

    var body: some View {
        HStack(spacing: 18) {  // ⬅️ Weniger Abstand

            hudItem(
                symbol: icons.level.symbol,
                color: Color(hex: icons.level.color),
                title: "Lv.",
                value: accountManager.level
            )

            hudItem(
                symbol: icons.coin.symbol,
                color: Color(hex: icons.coin.color),
                value: coinManager.coins
            )

            hudItem(
                symbol: icons.crystal.symbol,
                color: Color(hex: icons.crystal.color),
                value: crystalManager.crystals
            )

            hudItem(
                symbol: icons.shards.symbol,
                color: Color(hex: icons.shards.color),
                value: artefacts.totalShards
            )
        }
        .padding(.horizontal, 14)  // ⬅️ Weniger Außen-Padding
        .padding(.vertical, 14)  // ⬅️ Weniger Höhe
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .white.opacity(0.15), radius: 10, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 10)  // ⬅️ Rahmen auch kompakter
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
            ) {
                glow.toggle()
            }
        }
    }

    private func hudItem(
        symbol: String,
        color: Color,
        title: String? = nil,
        value: Int
    ) -> some View {
        HStack(spacing: 6) {

            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 30, height: 30)  // ⬅️ kleiner
                    .shadow(
                        color: color.opacity(glow ? 0.5 : 0.2),
                        radius: glow ? 8 : 2
                    )

                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))  // ⬅️ kleiner
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 0) {
                if let title = title {
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }

                Text("\(value)")
                    .font(.subheadline.weight(.bold))  // ⬅️ kleiner
                    .foregroundColor(.white)
            }

            Spacer(minLength: 0)
        }
        .frame(width: 70)  // ⬅️ kompakter
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HeaderView().environmentObject(CoinManager.shared).environmentObject(
        CrystalManager.shared
    ).environmentObject(AccountLevelManager.shared)
        .environmentObject(ArtefactInventoryManager.shared)
        .preferredColorScheme(.dark)
}
