//
//  ScreenFactory.swift
//

import SwiftUI

@MainActor
final class ScreenFactory {

    static let shared = ScreenFactory()

    // MARK: - Injected Global Controllers (aus App)
    private var game: SpiritGameController?
    private var environmentObjects: [AnyObject] = []

    // MARK: - Setup aus App
    func setGameController(_ controller: SpiritGameController) {
        self.game = controller
    }

 
    // MARK: - Public API
    func make(_ name: String) -> AnyView {
        guard game != nil else {
            return AnyView(missingGameControllerView())
        }

        let view: AnyView = switch name {

        // Core
        case "SettingsView": AnyView(SettingsView())
        case "SpiritGameView": AnyView(SpiritGameView())

        // Gifts / Daily
        case "GiftView": AnyView(GiftView())
        case "DailyLoginView": AnyView(DailyLoginView())

        // Game
        case "UpgradeView": AnyView(UpgradeView())
        case "ExchangeView": AnyView(ExchangeView())
        case "ArtefactView": AnyView(ArtefactView())
        case "QuestView": AnyView(QuestView())
        case "SpiritListView": AnyView(SpiritListView())
        case "EventShopInventoryView": AnyView(EventShopInventoryView())
        case "CustomViewBuilder": AnyView(CustomViewBuilder())

        case "EventView":
            AnyView(EventView())

        // Default fallback
        default:
            AnyView(fallbackView(for: name))
        }

        return injectAllEnvironmentObjects(into: view)
    }
}

extension ScreenFactory {

    // MARK: - Fehlender GameController
    private func missingGameControllerView() -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 60))

            Text("❌ SpiritGameController fehlt!")
                .foregroundColor(.white)
                .font(.title2.bold())
                .padding(.top, 8)

            Text("ScreenFactory.setGameController(_:) wurde nicht aufgerufen.")
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }

    // MARK: - Fallback Screen
    fileprivate func fallbackView(for name: String) -> some View {
        VStack(spacing: 18) {
            Image(systemName: "questionmark.app.fill")
                .font(.system(size: 66))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow, .orange)

            Text("Screen „\(name)“ nicht gefunden")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Text("Dieser Screen ist noch nicht in der ScreenFactory registriert.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.55))
        )
        .padding()
    }

    // MARK: - Environment Injection
    private func injectAllEnvironmentObjects(into view: AnyView) -> AnyView {
        var modified = AnyView(view)

        for object in environmentObjects {
            switch object {

            case let coin as CoinManager:
                modified = AnyView(modified.environmentObject(coin))

            case let crystal as CrystalManager:
                modified = AnyView(modified.environmentObject(crystal))

            case let account as AccountLevelManager:
                modified = AnyView(modified.environmentObject(account))

            case let gifts as GiftManager:
                modified = AnyView(modified.environmentObject(gifts))

            case let daily as DailyLoginManager:
                modified = AnyView(modified.environmentObject(daily))

            case let upgrades as UpgradeManager:
                modified = AnyView(modified.environmentObject(upgrades))

            case let artefacts as ArtefactInventoryManager:
                modified = AnyView(modified.environmentObject(artefacts))

            case let quests as QuestManager:
                modified = AnyView(modified.environmentObject(quests))

            case let events as EventShopManager:
                modified = AnyView(modified.environmentObject(events))

            case let music as MusicManager:
                modified = AnyView(modified.environmentObject(music))

            default:
                continue
            }
        }

        return modified
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
