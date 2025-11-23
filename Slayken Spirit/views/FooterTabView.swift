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
                SummonView()
            }
            .tabItem {
                Image(systemName: "sparkle")
                Text("Summon")
            }
            .tag(2)
            
            NavigationStack {
                ExchangeView()
            }
            .tabItem {
                Image(systemName: "arrow.trianglehead.2.counterclockwise")
                Text("Exchange")
            }
            .tag(3)
            
        NavigationStack {
            SettingsView()
        }
        .tabItem {
            Image(systemName: "gearshape.fill")
            Text("Settings")
        }
        .tag(4)
            NavigationStack {
                EventView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Event")
            }
            .tag(5)
            
        }
    }
}

#Preview {
    FooterTabView()
        .environmentObject(CoinManager.shared)
        .environmentObject(UpgradeManager.shared)
}
