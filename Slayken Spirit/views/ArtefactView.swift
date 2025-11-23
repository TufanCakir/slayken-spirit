import SwiftUI

struct ArtefactView: View {

    @ObservedObject private var inventory = ArtefactInventoryManager.shared

    // Lade Hintergrundbild aus JSON
    private let homeBG: String = {
        let spirits = Bundle.main.loadSpiritArray("spirits")
        return spirits.first?.background ?? "sky"
    }()

    var body: some View {
        NavigationStack {
            ZStack {

                HomeBackgroundView(imageName: homeBG)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 18) {

                        ForEach(inventory.owned) { art in
                            artefactCard(art)
                        }
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [.black, Color.white.opacity(0.3), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

extension ArtefactView {

    fileprivate func artefactCard(_ art: Artefact) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 12) {

                // ICON (Emoji oder SF Symbol)
                Image(systemName: art.displayIcon)
                    .font(.system(size: 28))
                    .foregroundColor(art.rarityColor)
                    .shadow(color: art.rarityColor, radius: 6)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(art.name)  Lv.\(art.level)")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(art.desc)
                        .font(.caption)
                        .foregroundColor(.white)
                }

                Spacer()

                rarityBadge(art.rarity)
            }

            // POWER Anzeige
            HStack {
                Text("Power: \(art.totalPower)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)

                Spacer()

                upgradeButton(art)
            }
        }
        .padding(16)
        .background(.black)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(art.rarityColor.opacity(0.7), lineWidth: 1.4)
        )
        .shadow(color: art.rarityColor.opacity(0.4), radius: 12)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

extension ArtefactView {

    fileprivate func upgradeButton(_ art: Artefact) -> some View {
        Button {
            ArtefactInventoryManager.shared.upgrade(art)
        } label: {
            Text("Upgrade")
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(art.rarityColor.opacity(0.2))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(art.rarityColor.opacity(0.8), lineWidth: 1)
                )
        }
    }
}

extension ArtefactView {

    fileprivate func rarityBadge(_ rarity: String) -> some View {
        let color: Color = {
            switch rarity.lowercased() {
            case "rare": return .blue
            case "epic": return .purple
            case "legendary": return .yellow
            default: return .gray
            }
        }()

        return Text(rarity.uppercased())
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .foregroundColor(.white)
    }
}
