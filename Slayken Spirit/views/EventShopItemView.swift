import SwiftUI

struct EventShopItemView: View {

    @EnvironmentObject private var shop: EventShopManager
    let item: EventShopItem

    @Binding var selectedItem: EventShopItem?
    @Binding var showPopup: Bool

    var body: some View {

        let stack = shop.currentStack(for: item)
        let active = shop.isActive(item)
        let required = item.required

        let progress = min(Double(stack) / Double(required), 1.0)

        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            active ? Color.green : Color.blue.opacity(0.5),
                            lineWidth: active ? 2.5 : 1.5
                        )
                )

            HStack(spacing: 16) {

                Image(systemName: item.icon)
                    .font(.system(size: 42))
                    .foregroundColor(active ? .green : .blue)

                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .foregroundColor(.white)
                        .font(.headline)

                    Text(item.description)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline)

                    // MARK: Fortschrittsbalken
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 8)

                        Capsule()
                            .fill(active ? .green : .blue)
                            .frame(width: 140 * progress, height: 8)
                            .animation(.easeInOut, value: stack)
                    }

                    Text(active ? "ACTIVE" : "\(stack) / \(required)")
                        .font(.caption.bold())
                        .foregroundColor(active ? .green : .white)
                }

                Spacer()

                // MARK: Buttons (Buy / Activate)
                VStack(spacing: 10) {

                    // --- KAUFEN ---
                    Button("Buy \(item.price)") {
                        selectedItem = item
                        showPopup = true
                    }
                    .font(.headline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .background(.blue)
                    .clipShape(Capsule())
                    .foregroundColor(.white)

                    // --- AKTIVIEREN ---
                    if stack >= required && !active {
                        Button("Activate") {
                            shop.activate(item)
                        }
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .background(.yellow)
                        .clipShape(Capsule())
                        .foregroundColor(.black)
                        .shadow(color: .yellow, radius: 8)
                        .transition(.opacity.combined(with: .scale))
                    }

                    // --- AKTIV ---
                    if active {
                        Text("✓ Active")
                            .font(.headline.bold())
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(18)
        }
        .padding(.horizontal, 2)
    }
}
