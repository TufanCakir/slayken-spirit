import SwiftUI

struct EventShopInventoryView: View {

    @EnvironmentObject private var shop: EventShopManager

    var body: some View {
        ZStack {

            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {

                Text("Inventory")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)

                if shop.inventory.isEmpty {
                    Text("Keine Items gekauft.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(shop.inventory) { item in
                                HStack {
                                    Image(systemName: item.icon)
                                        .font(.title2)
                                        .foregroundColor(.red)

                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .foregroundColor(.white)
                                        Text(item.description)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}
