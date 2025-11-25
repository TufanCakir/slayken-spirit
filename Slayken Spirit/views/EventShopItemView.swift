import SwiftUI

struct EventShopItemView: View {

    @EnvironmentObject private var shop: EventShopManager
    let item: EventShopItem

    @Binding var selectedItem: EventShopItem?
    @Binding var showPopup: Bool

    var body: some View {

        let alreadyBought = shop.hasBought(item)

        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)

            HStack(spacing: 16) {

                Image(systemName: item.icon)
                    .font(.system(size: 38))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .foregroundColor(.white)
                        .font(.headline)

                    Text(item.description)
                        .foregroundColor(.white)
                        .font(.headline)
                }

                Spacer()

                Button(alreadyBought ? "Bought" : "Buy \(item.price)") {
                    if alreadyBought {
                        return
                    }

                    selectedItem = item
                    showPopup = true
                }
                .font(.headline)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(alreadyBought ? .gray : .blue)
                .clipShape(Capsule())
                .foregroundColor(.white)
                .disabled(alreadyBought)
            }
            .padding(18)
        }
        .padding(.horizontal, 2)
    }
}


