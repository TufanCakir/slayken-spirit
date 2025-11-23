import SwiftUI

struct SummonView: View {

    @StateObject private var summon = SummonController()

    @State private var showError = false
    @State private var errorMessage = ""

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
                VStack(spacing: 25) {

                    Text("Summon")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    ForEach(summon.options) { option in
                        summonButton(option)
                    }

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $summon.showResult) {
                    SummonResultView(results: summon.summonResults)
                }

                // 🔥 ERROR BANNER
                if showError {
                    errorBanner(message: errorMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(50)
                }
            }
        }
    }
}

private extension SummonView {

    func summonButton(_ option: SummonOption) -> some View {
        Button {

            // CHECK RESOURCES
            if CoinManager.shared.coins < option.priceCoins {
                triggerError("Nicht genug Coins!")
                return
            }

            if CrystalManager.shared.crystals < option.priceCrystals {
                triggerError("Nicht genug Crystals!")
                return
            }

            summon.summon(option)

        } label: {
            VStack(spacing: 4) {
                Text(option.title)
                    .font(.title3.weight(.bold))
                Text("\(option.amount)x Pulls")
                    .font(.subheadline)
                    .opacity(0.7)

                HStack {
                    Image(systemName: "bitcoinsign.circle")
                    Text("\(option.priceCoins)")

                    Image(systemName: "diamond.fill")
                    Text("\(option.priceCrystals)")
                }
                .font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }
}

private extension SummonView {

    func triggerError(_ message: String) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)

        errorMessage = message
        withAnimation(.spring()) {
            showError = true
        }

        // Fade-out nach 2 Sekunden
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut) {
                showError = false
            }
        }
    }

    func errorBanner(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundColor(.yellow)

            Text(message)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 30)
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
}
