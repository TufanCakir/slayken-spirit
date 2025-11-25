import SwiftUI

struct FooterTabView: View {

    @State private var selectedTab: Int = 0
    @State private var showUpgrade = false

    var body: some View {
        TabView(selection: $selectedTab) {

            // -------------------------
            // 🔥 TAB 1 – HOME
            // -------------------------
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                UpgradeView()
            }
            .tabItem {
                Image(systemName: "arrow.up.circle.fill")
                Text("Upgrade")
            }
            .tag(1)
            
            NavigationStack {
                ArtefactView()
            }
            .tabItem {
                Image(systemName: "sparkles")
                Text("Artefact")
            }
            .tag(2)

            NavigationStack {
                EventShopView()
            }
            .tabItem {
                Image(systemName: "cart.fill")
                Text("Event Shop")
            }
            .tag(3)
        }
    }
}

#Preview {
    FooterTabView()
        .environmentObject(CoinManager.shared)
        .environmentObject(UpgradeManager.shared)
}
