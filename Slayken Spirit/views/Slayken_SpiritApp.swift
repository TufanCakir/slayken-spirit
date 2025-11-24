import SwiftUI

@main
struct Slayken_SpiritApp: App {

    @StateObject private var internet = InternetMonitor()

    @StateObject private var coinManager = CoinManager.shared
    @StateObject private var crystalManager = CrystalManager.shared
    @StateObject private var accountManager = AccountLevelManager.shared
    @StateObject private var giftManager = GiftManager.shared
    @StateObject private var dailyLoginManager = DailyLoginManager.shared
    @StateObject private var upgradeManager = UpgradeManager.shared
    @StateObject private var artefactInventoryManager = ArtefactInventoryManager.shared
    @StateObject private var spiritGame = SpiritGameController()
    @StateObject private var questManager = QuestManager.shared
    @StateObject private var musicManager = MusicManager()

    init() {
        GameCenterManager.shared.authenticate()
        ScreenFactory.shared.setGameController(spiritGame)
    }

    var body: some Scene {
        WindowGroup {

            Group {
                if internet.isConnected {
                    TutorialView()
                } else {
                    OfflineScreen()   // ⛔ Kein Internet → Offline-Screen
                }
            }
            .environmentObject(spiritGame)
            .environmentObject(coinManager)
            .environmentObject(crystalManager)
            .environmentObject(accountManager)
            .environmentObject(giftManager)
            .environmentObject(dailyLoginManager)
            .environmentObject(musicManager)
            .environmentObject(upgradeManager)
            .environmentObject(artefactInventoryManager)
            .environmentObject(questManager)
        }
    }
}
