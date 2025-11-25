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
                    Image(systemName: "flame.fill")
                        .font(.system(size: 42))
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.5), radius: 12)
                    
                    Text("Event Shop")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
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
                    LazyVStack(spacing: 22) {
                        ForEach(shop.items) { item in
                            EventShopItemView(
                                item: item,
                                selectedItem: $selectedItem,
                                showPopup: $showPopup
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                
                // MARK: - Inventory
                NavigationLink("Inventory") {
                    EventShopInventoryView()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 25)
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
