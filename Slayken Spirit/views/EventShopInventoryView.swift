import SwiftUI

struct EventShopInventoryView: View {

    @EnvironmentObject private var shop: EventShopManager

    var body: some View {
        ZStack {
                SpiritGridBackground()


            VStack(spacing: 20) {

                Text("Inventory")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                if shop.inventory.isEmpty {
                    Text("Keine Items gekauft.")
                        .foregroundColor(.gray)
                        .font(.headline)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(shop.inventory) { item in
                                inventoryCard(item)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

extension EventShopInventoryView {

    fileprivate func inventoryCard(_ item: EventShopItem) -> some View {

        let stack = item.stack
        let required = item.required
        let active = item.isActive

        let progress = min(Double(stack) / Double(required), 1.0)

        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            active ? .green : .blue.opacity(0.5),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: active ? .green.opacity(0.4) : .blue.opacity(0.2),
                    radius: 8,
                    y: 4
                )

            HStack(spacing: 16) {

                Image(systemName: item.icon)
                    .font(.system(size: 40))
                    .foregroundColor(active ? .green : .blue)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.name)
                            .foregroundColor(.white)
                            .font(.headline)

                        if active {
                            Text("ACTIVE")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Text(item.description)
                        .foregroundColor(.gray)
                        .font(.caption)
                        .lineLimit(2)

                    // MARK: Fortschritt
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 8)

                        Capsule()
                            .fill(active ? .green : .blue)
                            .frame(width: 150 * progress, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: stack)
                    }

                    Text(active ? "Fertig aktiviert" : "\(stack) / \(required)")
                        .foregroundColor(active ? .green : .white)
                        .font(.caption.bold())
                }

                Spacer()
            }
            .padding(16)
        }
    }
}

#Preview {
    EventShopInventoryView()
        .environmentObject(EventShopManager())
}
