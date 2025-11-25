import SwiftUI

struct ArtefactView: View {

    @ObservedObject private var inventory = ArtefactInventoryManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                SpiritGridBackground()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ForEach(inventory.owned) { art in
                            artefactCard(art)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

extension ArtefactView {

    fileprivate func artefactCard(_ art: Artefact) -> some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top, spacing: 14) {

                // MARK: - ICON
                ZStack {
                    Circle()
                        .fill(art.rarityColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                        .shadow(color: art.rarityColor.opacity(0.6), radius: 10)

                    Image(systemName: art.displayIcon)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(art.rarityColor)
                }

                // MARK: - TEXT + TITLE
                VStack(alignment: .leading, spacing: 6) {

                    HStack {
                        Text("\(art.name)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Text("Lv.\(art.level)")
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.yellow.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    Text(art.desc)
                        .foregroundColor(.white.opacity(0.75))
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                rarityBadge(art.rarity)
            }

            Divider().background(.white.opacity(0.2))

            // MARK: - Power Row
            HStack {
                Text("Power: \(art.totalPower)")
                    .font(.headline.bold())
                    .foregroundColor(.white)

                Spacer()

                upgradeButton(art)
            }

        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.06))
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(art.rarityColor.opacity(0.6), lineWidth: 1.3)
        )
        .shadow(color: art.rarityColor.opacity(0.35), radius: 14, y: 6)
    }
}

extension ArtefactView {

    fileprivate func upgradeButton(_ art: Artefact) -> some View {
        Button {
            ArtefactInventoryManager.shared.upgrade(art)
        } label: {
            Text("Upgrade")
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(colors: [art.rarityColor, art.rarityColor.opacity(0.65)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .clipShape(Capsule())
                .shadow(color: art.rarityColor.opacity(0.6), radius: 8)
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
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.9))
            )
            .shadow(color: color.opacity(0.7), radius: 6)
    }
}

#Preview {
    ArtefactView()
}
