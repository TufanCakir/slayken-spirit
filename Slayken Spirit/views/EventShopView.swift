import SwiftUI

struct EventShopView: View {

    @EnvironmentObject private var shop: EventShopManager

    @State private var selectedItem: EventShopItem? = nil
    @State private var showPopup = false
    @State private var showNotEnough = false

    var body: some View {
        ZStack {

            SpiritGridBackground()

            VStack(spacing: 26) {

                // MARK: - Titel
                VStack(spacing: 6) {

                }
                .padding(.top, 10)

                // MARK: - Spirit Points
                Text("Spirit Points: \(shop.spiritPoints)")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                // MARK: - Shop Items
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(shop.items) { item in
                            EventShopItemView(
                                item: item,
                                selectedItem: $selectedItem,
                                showPopup: $showPopup
                            )
                        }
                    }
                }

                // MARK: - Inventory
                NavigationLink("Inventory") {
                    EventShopInventoryView()
                }
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }

            // ⭐ POPUP ÜBER ALLEM
            if showPopup, let item = selectedItem {
                BuyConfirmPopup(
                    item: item,
                    onBuy: {
                        let success = shop.buyItem(item)
                        if !success {
                            showNotEnough = true
                        }
                        showPopup = false
                        selectedItem = nil
                    },
                    onCancel: {
                        showPopup = false
                        selectedItem = nil
                    }
                )
                .zIndex(999)
            }
        }
        .alert("Not enough Spirit Points!", isPresented: $showNotEnough) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    EventShopView()
        .environmentObject(EventShopManager.shared)
}
