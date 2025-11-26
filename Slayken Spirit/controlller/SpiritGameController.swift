//
//  SpiritGameController.swift
//  Slayken Spirit
//

import Foundation
import GameKit
internal import Combine

// MARK: - Game Action Structure
struct GameAction: Codable {
    enum ActionType: String, Codable {
        case attack
        case itemCollected
        case experienceGained
        case bossDefeated // Hinzugefügt für Synchronisation
    }
    let type: ActionType
    let playerID: String // Wer die Aktion ausgeführt hat
    let value: Int // Schaden, Item-ID, etc.
}

// MARK: - Notification Name
extension Notification.Name {
    static let multiplayerDidReceiveAction = Notification.Name("MultiplayerDidReceiveAction")
}

@MainActor
final class SpiritGameController: ObservableObject {
    
    
    // MARK: - Published: UI States
    @Published private(set) var current: ModelConfig
    @Published private(set) var currentHP: Int
    @Published private(set) var stage: Int = {
        let saved = UserDefaults.standard.integer(forKey: "savedStage")
        return max(saved, 1) // nie 0
    }()
    @Published private(set) var point: Int = {
        let saved = UserDefaults.standard.integer(forKey: "savedPoint")
        return max(saved, 1) // nie 0
    }()
    @Published private(set) var backgroundName: String
    @Published var backgroundFade: Double = 0
    @Published var isAutoBattle: Bool = false
    
    // MARK: - Stats fürs Game Center
    @Published var totalKills: Int = UserDefaults.standard.integer(forKey: "totalKills")
    @Published var totalQuests: Int = UserDefaults.standard.integer(forKey: "totalQuests")
    @Published var playtimeMinutes: Int = UserDefaults.standard.integer(forKey: "playtimeMinutes")
    @Published var isInEvent: Bool = false
    @Published var eventWon: Bool = false
    
    private var autoBattleTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private func saveStats() {
        UserDefaults.standard.set(totalKills, forKey: "totalKills")
        UserDefaults.standard.set(totalQuests, forKey: "totalQuests")
        UserDefaults.standard.set(playtimeMinutes, forKey: "playtimeMinutes")
    }
    
    // MARK: - Data
    private let all: [ModelConfig]
    
    // MARK: - Init
    init() {
        
        let loaded = Bundle.main.loadSpiritArray("spirits")
        guard let first = loaded.first else {
            fatalError("❌ spirits.json hat keine Einträge")
        }
        
        self.all = loaded
        self.current = first
        self.currentHP = first.hp + ArtefactInventoryManager.shared.bonusHP
        self.backgroundName = first.background ?? "sky"
        
        setupArtefactListener()
        setupMultiplayerListener() // <--- NEU: Rufe den Listener hier auf
    }
    
    
    
    // MARK: - Multiplayer Listener
    private func setupMultiplayerListener() {
        NotificationCenter.default.publisher(for: .multiplayerDidReceiveAction)
            .compactMap { $0.userInfo }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                self?.handleMultiplayerAction(userInfo: userInfo)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Artefact Change Listener
    private func setupArtefactListener() {
        ArtefactInventoryManager.shared.objectWillChange
            .sink { [weak self] _ in
                self?.recalculateHP()
            }
            .store(in: &cancellables)
    }
    
    private func recalculateHP() {
        currentHP = max(1, current.hp + ArtefactInventoryManager.shared.bonusHP)
        objectWillChange.send()
    }
    
    
    // MARK: - Event Start
    func startEvent(_ event: GameEvent) {
        print("🔥 [EVENT] StartEvent aufgerufen")
        print("🔥 [EVENT] Event ID: \(event.id)")
        print("🔥 [EVENT] bossId aus JSON: \(event.bossId)")
        
        // Markiere Event als aktiv
        isInEvent = true
        
        print("🎯 [STATE] isInEvent = true")
        
        print("📦 [SPIRITS] Anzahl geladene Spirits: \(all.count)")
        for s in all {
            print("   → Spirit: \(s.id) (model: \(s.modelName) )")
        }
        
        guard let boss = all.first(where: { $0.id == event.bossId }) else {
            print("❌ Boss für Event nicht gefunden:", event.bossId)
            return
        }
        
        print("✅ [EVENT] Gefundener Boss: \(boss.id)")
        print("   → modelName: \(boss.modelName)")
        print("   → hp: \(boss.hp)")
        print("   → background: \(boss.background ?? "none")")
        
        // Boss setzen
        current = boss
        currentHP = boss.hp + ArtefactInventoryManager.shared.bonusHP
        print("💙 [HP] HP gesetzt auf: \(currentHP)")
        
        updateBackground(for: boss)
        
        // UI Refresh
        objectWillChange.send()
        print("🎉 Event Start abgeschlossen!")
    }
    
    func handleEventVictory() {
        print("🔥 EVENT GEWONNEN – SPIRIT POINTS +10")
        
        // Punkte vergeben
        EventShopManager.shared.spiritPoints += 10
        
        // Event wird beendet
        isInEvent = false
        
        // Trigger für UI damit EventGameView geschlossen wird
        eventWon = true
    }
    
    // Im SpiritGameController:
    
    // MARK: - Multiplayer Action Handler
    private func handleMultiplayerAction(userInfo: [AnyHashable: Any]) {
        guard let action = userInfo["action"] as? GameAction,
              let player = userInfo["fromPlayer"] as? GKPlayer
        else {
            print("❌ MP Handler: Ungültige Action- oder Player-Daten.")
            return
        }
        
        if action.type == .attack {
            let newHP = max(0, currentHP - action.value)
            currentHP = newHP
            
            print("💥 [MP Game] \(player.displayName) verursacht \(action.value) Schaden. Neue HP: \(currentHP)")
            
            if newHP == 0 {
                // Wenn der Boss besiegt ist, senden WIR ein synchronisiertes Signal.
                // Es ist unwahrscheinlich, dass zwei Clients GLEICHZEITIG auf 0 setzen,
                // aber es kann passieren. Game Center garantiert die Reihenfolge nicht immer 100%,
                // aber dies ist der beste Ansatz.
                
                // Sende das Defeat-Signal (alle anderen werden darauf reagieren)
                let defeatAction = GameAction(
                    type: .bossDefeated,
                    playerID: GKLocalPlayer.local.playerID,
                    value: stage // Sende die aktuelle Stage als Wert
                )
                MatchManager.shared.sendActionData(defeatAction)
            }
        }
        // NEU: Empfange das Defeat-Signal
        else if action.type == .bossDefeated {
            // HIER: Alle Spieler erhalten das Defeat-Signal und führen die goToNext-Logik aus.
            // Die Rewards müssen in dieser goToNext-Funktion nur EINMAL ausgeführt werden.
            
            // Da die goToNext() Funktion bereits die Rewards gibt:
            handleMultiplayerDefeat()
        }
    }
    
    // IN SpiritGameController.swift
    // NEU: Separate Defeat-Funktion für Multiplayer, die keine Rewards gibt
    private func handleMultiplayerDefeat() {
        // Hier können visuelle Effekte für den Sieg im Multiplayer hinzugefügt werden
        print("🎉 SYNCHRONISIERTER MP-SIEG! Wechsle zur nächsten Stage.")
        
        // Die Rewards (Coins, Exp etc.) MÜSSEN im MP-Modus anders behandelt werden,
        // um Duplikate zu vermeiden. Vorerst nur die Spielfortschritt-Logik:
        rollArtefactDrop() // Artefakte sind lokal und können fallen
        goToNext()
    }

    // MARK: - Player Tap
    func tapAttack() {
        guard currentHP > 0 else { return }
        
        // Schaden berechnen (lokal, da Crit-Chance etc. nur vom lokalen Spieler abhängt)
        let base = UpgradeManager.shared.tapDamage + ArtefactInventoryManager.shared.bonusTapDamage
        let damage = calculateDamage(base: base)
        
        // NEU: Unterscheidung zwischen Singleplayer und Multiplayer
        if MatchManager.shared.isMatchActive {
            // --- MULTIPLAYER-PFAD ---
            
            // 1. Definiere die Aktion
            let attack = GameAction(
                type: .attack,
                playerID: GKLocalPlayer.local.playerID,
                value: damage
            )
            
            // 2. Sende die Aktion an alle Spieler
            MatchManager.shared.sendActionData(attack)
            
            // WICHTIG: Die tatsächliche HP-Änderung findet JETZT NICHT statt.
            // Sie wird erst durchgeführt, wenn der MatchManager die GESENDETEN
            // Daten ÜBER DAS NETZWERK ZURÜCK empfängt (siehe unten).
            
        } else {
            // --- SINGLEPLAYER-PFAD (Bestehende Logik) ---
            
            currentHP = max(0, currentHP - damage)
            
            if currentHP == 0 {
                if isInEvent {
                    handleEventVictory()
                } else {
                    handleDefeat()
                }
            }
        }
    }

    // MARK: - Crit System
    private func calculateDamage(base: Int) -> Int {

        let critChance = ArtefactInventoryManager.shared.bonusCritChance
        let critDamage = ArtefactInventoryManager.shared.bonusCritDamage

        let roll = Double.random(in: 0...100)

        if roll <= critChance {
            return Int(Double(base) * (1 + critDamage / 100.0))
        }

        return base
    }

    // MARK: - AutoBattle
    func toggleAutoBattle() {
        isAutoBattle.toggle()
        isAutoBattle ? startAutoBattle() : stopAutoBattle()
    }
    
    func resetStats() {
        totalKills = 0
        totalQuests = 0
        playtimeMinutes = 0

        UserDefaults.standard.set(0, forKey: "totalKills")
        UserDefaults.standard.set(0, forKey: "totalQuests")
        UserDefaults.standard.set(0, forKey: "playtimeMinutes")
        UserDefaults.standard.set(1, forKey: "savedStage")

        stage = 1
        print("🔄 SpiritGame Stats reset!")
    }


    private func startAutoBattle() {

        stopAutoBattle()

        let speedPercent = ArtefactInventoryManager.shared.bonusAttackSpeed
        let interval = max(0.05, 0.18 * (1 - speedPercent / 100))

        autoBattleTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.currentHP > 0 {
                    self.tapAttack()
                } else {
                    self.stopAutoBattle()
                }
            }
        }

        RunLoop.main.add(autoBattleTimer!, forMode: .common)
    }

    private func stopAutoBattle() {
        autoBattleTimer?.invalidate()
        autoBattleTimer = nil
    }

    // MARK: - Defeat
    private func handleDefeat() {
        giveReward()
        rollArtefactDrop()
        goToNext()
    }

    // MARK: - Artefact Drop
    private func rollArtefactDrop() {

        let total = ArtefactInventoryManager.shared.total
        GCArtefacts.submit(total)
        GameCenterRewardService.shared.rewardForArtefacts(total)

        let artefacts = Bundle.main.loadArtefacts("artefacts")
        let lootBoost = ArtefactInventoryManager.shared.bonusLootBoost

        for art in artefacts {
            var chance = art.dropChance + (lootBoost / 100.0)
            chance = min(chance, 0.95) // Hard cap
            if Double.random(in: 0...1) <= chance {
                ArtefactInventoryManager.shared.addArtefact(art)
            }
        }
    }

    // MARK: - Rewards
    private func giveReward() {
        guard let reward = current.reward else { return }

        let expBonus = ArtefactInventoryManager.shared.bonusExp
        let coinBonus = ArtefactInventoryManager.shared.bonusCoins

        CoinManager.shared.addCoins(reward.coins + coinBonus)
        CrystalManager.shared.addCrystals(reward.crystals)
        AccountLevelManager.shared.addExp(reward.exp + expBonus)
    }

    // MARK: - Next Spirit
    private func goToNext() {
        guard let idx = all.firstIndex(where: { $0.id == current.id }) else { return }

        // Nächster Spirit
        let nextIndex = (idx + 1) % all.count
        let next = all[nextIndex]

        // Stage erhöhen
        stage += 1
        point += 1
        UserDefaults.standard.set(stage, forKey: "savedStage")

        // 🔥 Game Center + Rewards
        GCKills.submit(totalKills)
        GameCenterRewardService.shared.rewardForKills(totalKills)

        GCQuests.submit(totalQuests)
        GameCenterRewardService.shared.rewardForQuests(totalQuests)

        GCPlaytime.submit(playtimeMinutes)
        GameCenterRewardService.shared.rewardForPlaytime(playtimeMinutes)

        GCHighestStage.submit(stage)
        GameCenterRewardService.shared.rewardForStage(stage)

        // Stats speichern
        saveStats()

        // Spirit Update
        current = next
        recalculateHP()

        // Hintergrund animiert wechseln
        updateBackground(for: next)
    }
    
    // MARK: - Background Change
    private func updateBackground(for next: ModelConfig) {

        let newBG = next.background ?? "sky"
        guard newBG != backgroundName else { return }

        backgroundFade = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.backgroundName = newBG
            self.backgroundFade = 0
        }
    }

}
