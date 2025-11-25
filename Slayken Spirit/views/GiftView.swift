//
//  GiftView.swift
//  Slayken Fighter of Fists
//

import SwiftUI

struct GiftView: View {

    @EnvironmentObject var giftManager: GiftManager

    // MARK: - Example Gifts
    private let gifts: [GiftItem] = [
        GiftItem(id: "daily_1", title: "Tägliches Geschenk", description: "+100 Coins", image: "gift_icon_1", reward: .init(coins: 100, crystals: nil)),
        GiftItem(id: "daily_2", title: "Bonus Geschenk", description: "+100 Crystals", image: "gift_icon_2", reward: .init(coins: nil, crystals: 100)),
        GiftItem(id: "daily_3", title: "Tägliches Geschenk", description: "+200 Coins", image: "gift_icon_3", reward: .init(coins: 200, crystals: nil)),
        GiftItem(id: "daily_4", title: "Bonus Geschenk", description: "+200 Crystals", image: "gift_icon_4", reward: .init(coins: nil, crystals: 200)),
        GiftItem(id: "daily_5", title: "Tägliches Geschenk", description: "+300 Coins", image: "gift_icon_5", reward: .init(coins: 300, crystals: nil)),
        GiftItem(id: "daily_6", title: "Bonus Geschenk", description: "+300 Crystals", image: "gift_icon_6", reward: .init(coins: nil, crystals: 300))
    ]

    // MARK: - Popup
    @State private var showPopup = false
    @State private var popupText = ""

  
    
    // MARK: - Unclaimed gifts
    private var unclaimedGifts: [GiftItem] {
        gifts.filter { !giftManager.isClaimed($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SpiritGridBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Title
                        Text("Geschenke")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 10)

                        // Collect All Button
                        allCollectButton

                        // Gift Cards
                        ForEach(gifts) { gift in
                            giftCard(for: gift)
                        }
                    }
                    .padding(.bottom, 40)
                }

                // Popup
                if showPopup {
                    VStack {
                        Text(popupText)
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .padding()
                            .background(.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 40)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }



    // MARK: - Collect ALL Button
    private var allCollectButton: some View {
        Button {
            if unclaimedGifts.isEmpty {
                popupText = "⚠️ Keine Geschenke übrig"
            } else {
                for gift in unclaimedGifts {
                    _ = giftManager.claim(gift)
                }
                popupText = "🎉 Alle Geschenke erhalten!"
            }

            showPopup = true
            hidePopup()

        } label: {
            Text("Alle abholen")
                .font(.headline.bold())
                .foregroundColor(.white )
                .padding(.vertical, 10)
                .padding(.horizontal, 28)
                .background(
                    LinearGradient(colors: [.blue, .blue, .blue],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(12)
        }
        .opacity(unclaimedGifts.isEmpty ? 0.4 : 1)
        .disabled(unclaimedGifts.isEmpty)
        .padding(.horizontal)
    }

    // MARK: - Gift Card
    private func giftCard(for gift: GiftItem) -> some View {
        let iconKey = gift.reward.coins != nil ? "coin" : "crystal"
        let hudIcon = HudIconManager.shared.icon(for: iconKey)

        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.blue, lineWidth: 3)
                )
                .shadow(color: .cyan.opacity(0.3), radius: 10, y: 4)

            HStack(spacing: 14) {

                if let h = hudIcon {
                    Image(systemName: h.symbol)
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: h.color))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(gift.title)
                        .font(.headline.bold())
                        .foregroundColor(.white)

                    Text(gift.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                if giftManager.isClaimed(gift.id) {
                    Text("Abgeholt")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                } else {
                    claimButton(for: gift)
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }

    // MARK: - Single Gift Claim Button
    private func claimButton(for gift: GiftItem) -> some View {
        Button {
            if giftManager.claim(gift) {
                popupText = "🎉 Geschenk erhalten!"
            } else {
                popupText = "⚠️ Bereits abgeholt"
            }

            showPopup = true
            hidePopup()

        } label: {
            Text("Abholen")
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(
                    LinearGradient(colors: [.blue, .blue, .blue],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(10)
                .shadow(color: .cyan.opacity(0.6), radius: 8, y: 3)
        }
    }

    // MARK: - Popup Hide Logic
    private func hidePopup() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showPopup = false
            }
        }
    }
}

#Preview {
    GiftView()
        .environmentObject(GiftManager.shared)
        .preferredColorScheme(.dark)
}
