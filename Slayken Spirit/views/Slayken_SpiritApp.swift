import SwiftUI
internal import GameKit

@main
struct Slayken_SpiritApp: App {

    // MARK: - Managers / Game State
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
    @StateObject private var eventShopManager = EventShopManager.shared

    
    // MARK: - Init (App Setup)
    init() {
        // Übergibt GameController an Factory
        ScreenFactory.shared.setGameController(spiritGame)
        
        // Game Center floating bubble
        GKAccessPoint.shared.isActive = true
        GKAccessPoint.shared.location = .topLeading
        
        // Game Center Login bei Start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            GameCenterManager.shared.authenticate()
        }
    }


    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear {
                    musicManager.configureAudioSession()
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
                .environmentObject(eventShopManager)
                .environmentObject(internet)
        }
    }

    // MARK: - Root View
    @ViewBuilder
    private var rootView: some View {
        if internet.isConnected {
            TutorialView()
        } else {
            OfflineScreen()
        }
    }
}
