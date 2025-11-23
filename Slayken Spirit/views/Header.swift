import SwiftUI

struct HeaderView: View {

    // MARK: - EnvironmentObjects
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var crystalManager: CrystalManager
    @EnvironmentObject var accountManager: AccountLevelManager

    // MARK: - Icons aus JSON
    @State private var icons: HUDIconSet = Bundle.main.decode("hudIcons.json")

    // MARK: - Glow Animation
    @State private var glow = false

    var body: some View {
        HStack(spacing: 20) {
            hudItem(
                symbol: icons.level.symbol,
                color: Color(hex: icons.level.color),
                value: accountManager.level,
                label: "Lv."
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
        }
        .frame(width: 400)
        .padding(.horizontal, 0)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.black)
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

    // MARK: - HUD Item (Verbessert)
    private func hudItem(symbol: String, color: Color, value: Int, label: String? = nil) -> some View {
        HStack(spacing: 6) {

            // Animated Glow Icon
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundColor(color)
                .shadow(color: color.opacity(glow ? 0.7 : 0.2), radius: glow ? 10 : 3)
                .scaleEffect(glow ? 1.05 : 1.0)

            // Label + Value
            if let label = label {
                Text("\(label) \(value)")
                    .font(.system(size: 0))
                    .foregroundColor(.white.opacity(0.9))
            } else {
                Text("\(value)")
                    .font(.system(size: 0))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.03))
                .overlay(
                    Capsule()
                        .stroke(color, lineWidth: 1)
                )
        )
    }
}

#Preview {
    HeaderView()
        .environmentObject(CoinManager.shared)
        .environmentObject(CrystalManager.shared)
        .environmentObject(AccountLevelManager.shared)
        .preferredColorScheme(.dark)
}
