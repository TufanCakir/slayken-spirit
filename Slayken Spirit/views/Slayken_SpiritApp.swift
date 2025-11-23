//
//  Slayken_SpiritApp.swift
//  Slayken Spirit
//
//  Created by Tufan Cakir on 22.11.25.
//

import SwiftUI

@main
struct Slayken_SpiritApp: App {
    @StateObject private var coinManager = CoinManager.shared
    @StateObject private var crystalManager = CrystalManager.shared
    @StateObject private var accountManager = AccountLevelManager.shared
    @StateObject private var giftManager = GiftManager.shared
    @StateObject private var dailyLoginManager = DailyLoginManager.shared
    @StateObject private var upgradeManager = UpgradeManager.shared
    @StateObject private var artefactInventoryManager = ArtefactInventoryManager.shared


    // MARK: - Non-Singleton
    @StateObject private var musicManager = MusicManager()

    // MARK: - Scene
    var body: some Scene {
        WindowGroup {

            FooterTabView()
                .preferredColorScheme(.dark)

                // MARK: - Reihenfolge beachten!
                // 1️⃣ Shop lädt equipment.json

                // MARK: - UI / System / Player Progress
                .environmentObject(coinManager)
                .environmentObject(crystalManager)
                .environmentObject(accountManager)

                // MARK: - Social / Daily Features
                .environmentObject(giftManager)
                .environmentObject(dailyLoginManager)
            
                // MARK: - Audio
                .environmentObject(musicManager)
            
                .environmentObject(upgradeManager)
                .environmentObject(artefactInventoryManager)


        }
    }
}
