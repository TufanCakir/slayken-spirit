//
//  ScreenFactory.swift
//  Slayken Fighter of Fists
//
//  Created by Tufan Cakir on 2025-10-30.
//

import SwiftUI

// MARK: - 🧭 ScreenFactory
@MainActor
final class ScreenFactory {

    static let shared = ScreenFactory()

    private var game: SpiritGameController?

    func setGameController(_ controller: SpiritGameController) {
        self.game = controller
    }

    // MARK: Public API
    func make(_ name: String) -> AnyView {
        switch name {

        // MARK: ⚙️ Core Screens
        case "SettingsView": return AnyView(SettingsView())

        // MARK: 🎁 Gifts / Daily
        case "GiftView": return AnyView(GiftView())
        case "DailyLoginView": return AnyView(DailyLoginView())
        case "SpiritGameView":
            guard let game = game else {
                fatalError(
                    "❌ SpiritGameController fehlt in ScreenFactory! setGameController zuerst aufrufen."
                )
            }
            return AnyView(SpiritGameView().environmentObject(game))

        case "UpgradeView": return AnyView(UpgradeView())
        case "ExchangeView": return AnyView(ExchangeView())
        case "ArtefactView": return AnyView(ArtefactView())
        case "HallOfFameView": return AnyView(HallOfFameView())
        case "EventShopInventoryView": return AnyView(EventShopInventoryView())
        case "QuestView": return AnyView(QuestView())
        case "MultiplayerView": return AnyView(MultiplayerView())
        case "CustomViewBuilder": return AnyView(CustomViewBuilder())
        case "SpiritListView":
            return AnyView(SpiritListView())
        case "EventView":
            guard let game = game else {
                fatalError(
                    "❌ SpiritGameController fehlt in ScreenFactory! setGameController zuerst aufrufen."
                )
            }
            return AnyView(EventView().environmentObject(game))

        // MARK: 🧩 Fallback
        default:
            return AnyView(ScreenFactory.fallbackView(for: name))
        }
    }
}

// MARK: - 🔧 Erweiterungen
extension ScreenFactory {

    /// Erstellt eine SpiritGameView basierend auf JSON-Daten.
    fileprivate static func makeSpiritGameView() -> AnyView {
        do {
            let allSpirits: [Spirit] = try Bundle.main.decodeSafe(
                "spirits.json"
            )

            guard allSpirits.first != nil else {
                return AnyView(
                    fallbackView(for: "SpiritGameView – keine Spirit-Daten")
                )
            }

            // 🔥 Manager
            let coin = CoinManager.shared
            let crystal = CrystalManager.shared
            let account = AccountLevelManager.shared

            // 👑 View erzeugen
            let view = SpiritGameView()
                .environmentObjects(coin, crystal, account)

            return AnyView(view)

        } catch {
            print(
                "⚠️ [ScreenFactory] Fehler beim Laden von spirits.json:",
                error
            )
            return AnyView(fallbackView(for: "SpiritGameView (JSON-Fehler)"))
        }
    }

    // MARK: Fallback
    fileprivate static func fallbackView(for name: String) -> some View {
        VStack(spacing: 18) {

            Image(systemName: "questionmark.app.fill")
                .font(.system(size: 66))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow, .orange)

            Text("Screen „\(name)“ nicht gefunden")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Text(
                "Dieser Screen ist noch nicht in der ScreenFactory registriert."
            )
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.65))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)

            Divider()
                .background(Color.white.opacity(0.25))
                .padding(.vertical, 8)

            Button {
                print("🐞 Debug: Screen '\(name)' fehlt in ScreenFactory.make()")
            } label: {
                Label("Debug-Log anzeigen", systemImage: "ladybug.fill")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.55))
                .shadow(color: .black.opacity(0.6), radius: 10, y: 4)
        )
        .padding()
    }
}

// MARK: - 🧰 Bundle Helper
extension Bundle {
    func decodeSafe<T: Decodable>(_ file: String) throws -> T {
        guard let url = url(forResource: file, withExtension: nil) else {
            throw NSError(
                domain: "ScreenFactory.FileNotFound",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "\(file) nicht gefunden"]
            )
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NSError(
                domain: "ScreenFactory.DecodeError",
                code: 500,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Fehler beim Decodieren von \(file): \(error)"
                ]
            )
        }
    }
}

// MARK: - 🧩 EnvironmentObject Helper
extension View {
    func environmentObjects(
        _ coin: CoinManager,
        _ crystal: CrystalManager,
        _ account: AccountLevelManager
    ) -> some View {
        self.environmentObject(coin)
            .environmentObject(crystal)
            .environmentObject(account)
    }
}
