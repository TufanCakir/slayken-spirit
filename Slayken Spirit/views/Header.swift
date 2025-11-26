import SwiftUI

struct HeaderView: View {

    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var crystalManager: CrystalManager
    @EnvironmentObject var accountManager: AccountLevelManager
    @EnvironmentObject var artefacts: ArtefactInventoryManager   // Shards kommen von hier

    @State private var icons: HUDIconSet = Bundle.main.decode("hudIcons.json")
    @State private var glow = false

    var body: some View {
        HStack(spacing: 20) {

            // LEVEL
            hudItem(
                symbol: icons.level.symbol,
                color: Color(hex: icons.level.color),
                value: accountManager.level,
                label: "Lv."
            )

            // COINS
            hudItem(
                symbol: icons.coin.symbol,
                color: Color(hex: icons.coin.color),
                value: coinManager.coins
            )

            // CRYSTALS
            hudItem(
                symbol: icons.crystal.symbol,
                color: Color(hex: icons.crystal.color),
                value: crystalManager.crystals
            )

            // ⭐ SHARDS — NEU
            hudItem(
                symbol: icons.shards.symbol,
                color: Color(hex: icons.shards.color),
                value: artefacts.totalShards,
            )
        }
        
        .frame(width: 400)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white, lineWidth: 1)
                )
                .shadow(color: .white, radius: 10, y: 4)
        )
        .padding(.horizontal)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                glow.toggle()
            }
        }
    }

    private func hudItem(symbol: String, color: Color, value: Int, label: String? = nil) -> some View {
        HStack(spacing: 6) {

            Image(systemName: symbol)
                .font(.system(size: 12))
                .foregroundColor(color)
                .shadow(color: color.opacity(glow ? 0.7 : 0.2), radius: glow ? 10 : 3)
                .scaleEffect(glow ? 1.05 : 1.0)

            if let label = label {
                Text("\(label) \(value)")
                    .foregroundColor(.white)
            } else {
                Text("\(value)")
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(color, lineWidth: 1)
                )
        )
    }
}

#Preview {
    HeaderView() .environmentObject(CoinManager.shared) .environmentObject(CrystalManager.shared) .environmentObject(AccountLevelManager.shared)
        .environmentObject(ArtefactInventoryManager.shared) .preferredColorScheme(.dark)
}
