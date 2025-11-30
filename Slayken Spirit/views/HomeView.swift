import SwiftUI

struct HomeView: View {

    @EnvironmentObject var musicManager: MusicManager

    // 👉 Buttons bleiben stabil
    @State private var buttons: [HomeButton] = Bundle.main.decode("homeButtons.json")

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                
                // MARK: Hintergrund (GPU-optimiert)
                SpiritGridBackground()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    
                    HeaderView()

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 24) {

                            // MARK: Home Buttons
                            ForEach(buttons) { button in
                                NavigationLink {
                                    ScreenFactory.shared.make(button.destination)
                                } label: {
                                    HomeButtonView(button: button)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 22)
                        .padding(.bottom, 60)
                    }
                }
                .zIndex(1)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MusicManager())
        .environmentObject(SpiritGameController())   // ✔ Preview OK
        .environmentObject(CoinManager.shared)
        .environmentObject(CrystalManager.shared)
        .environmentObject(AccountLevelManager.shared)
        .environmentObject(ArtefactInventoryManager.shared)
        .environmentObject(EventShopManager.shared)
        .preferredColorScheme(.dark)
}
