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
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                )

            HStack(spacing: 16) {

                Image(systemName: item.icon)
                    .font(.system(size: 38))
                    .foregroundColor(.red)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .foregroundColor(.white)
                        .font(.headline)

                    Text(item.description)
                        .foregroundColor(.white.opacity(0.7))
                        .font(.subheadline)
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
                .background(alreadyBought ? .gray : .red)
                .clipShape(Capsule())
                .foregroundColor(.white)
                .disabled(alreadyBought)
            }
            .padding(18)
        }
        .padding(.horizontal, 2)
    }
}
