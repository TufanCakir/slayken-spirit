internal import GameKit
import SwiftUI

@main
struct Slayken_SpiritApp: App {

    // MARK: - Hauptzustände und Manager
    @StateObject private var spiritGame = SpiritGameController()
    @StateObject private var musicManager = MusicManager()
    @StateObject private var internet = InternetMonitor()

    // MARK: - Singleton-Manager
    @StateObject private var coinManager = CoinManager.shared
    @StateObject private var crystalManager = CrystalManager.shared
    @StateObject private var accountManager = AccountLevelManager.shared
    @StateObject private var giftManager = GiftManager.shared
    @StateObject private var dailyLoginManager = DailyLoginManager.shared
    @StateObject private var upgradeManager = UpgradeManager.shared
    @StateObject private var artefactInventoryManager = ArtefactInventoryManager.shared
    @StateObject private var questManager = QuestManager.shared
    @StateObject private var eventShopManager = EventShopManager.shared

    // MARK: - Initialisierung (wichtig für PREVIEW)
    init() {
        // 💡 Preview verwendet dieses Setup!
        ScreenFactory.shared.setGameController(spiritGame)
    }

    // MARK: - Hauptszene
    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear {
                    // 💡 Echte App verwendet dieses Setup!
                    ScreenFactory.shared.setGameController(spiritGame)
                    GameCenterManager.shared.authenticate()
                    musicManager.configureAudioSession()
                }
                .environmentObject(spiritGame)
                .environmentObject(musicManager)
                .environmentObject(internet)
                .environmentObject(coinManager)
                .environmentObject(crystalManager)
                .environmentObject(accountManager)
                .environmentObject(giftManager)
                .environmentObject(dailyLoginManager)
                .environmentObject(upgradeManager)
                .environmentObject(artefactInventoryManager)
                .environmentObject(questManager)
                .environmentObject(eventShopManager)
        }
    }

    @ViewBuilder
    private var rootView: some View {
        if internet.isConnected {
            TutorialView()
        } else {
            OfflineScreen()
        }
    }
}
