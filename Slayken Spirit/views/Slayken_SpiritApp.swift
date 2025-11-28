internal import GameKit
import SwiftUI

@main
struct Slayken_SpiritApp: App {

    // MARK: - Game State + Manager (Singletons via .shared)
    @StateObject private var spiritGame = SpiritGameController()
    @StateObject private var internet = InternetMonitor()
    @StateObject private var coinManager = CoinManager.shared
    @StateObject private var crystalManager = CrystalManager.shared
    @StateObject private var accountManager = AccountLevelManager.shared
    @StateObject private var giftManager = GiftManager.shared
    @StateObject private var dailyLoginManager = DailyLoginManager.shared
    @StateObject private var upgradeManager = UpgradeManager.shared
    @StateObject private var artefactInventoryManager = ArtefactInventoryManager
        .shared
    @StateObject private var questManager = QuestManager.shared
    @StateObject private var musicManager = MusicManager()
    @StateObject private var eventShopManager = EventShopManager.shared

    // MARK: - Init Setup
    init() {
        // Übergibt GameController an ScreenFactory
        ScreenFactory.shared.setGameController(spiritGame)

        // Game Center Login (automatisch bei App-Start)
        GameCenterManager.shared.authenticate()
    }

    // MARK: - Main Scene
    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear {
                    musicManager.configureAudioSession()
                }
                .environmentObject(spiritGame)
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
                .environmentObject(musicManager)
        }
    }

    // MARK: - Root View Switcher (Online vs Offline)
    @ViewBuilder
    private var rootView: some View {
        if internet.isConnected {
            TutorialView()
        } else {
            OfflineScreen()
        }
    }
}
