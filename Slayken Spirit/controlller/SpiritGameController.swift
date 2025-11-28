//
//  SpiritGameController.swift
//  Slayken Spirit
//

import Foundation
internal import GameKit
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

    @Published var isAutoBattle: Bool = false
    
    // MARK: - Active Event
    private var activeEvent: GameEvent?
    
    // MARK: - Stats fürs Game Center
    @Published var totalKills: Int = UserDefaults.standard.integer(forKey: "totalKills")
    @Published var totalQuests: Int = UserDefaults.standard.integer(forKey: "totalQuests")
    @Published var playtimeMinutes: Int = UserDefaults.standard.integer(forKey: "playtimeMinutes")
    @Published var isInEvent: Bool = false
    @Published var eventWon: Bool = false
    @Published var eventBossList: [String] = []
    @Published var eventBossIndex: Int = 0
    @Published var currentEventGridColor: String = "#00AACC"

    @Published var currentEvent: MultiplayerEvent?
    @Published var currentBosses: [MultiplayerBoss] = []
    @Published var currentMultiplayerIndex: Int = 0
    @Published var isInMultiplayerMode: Bool = false
    @Published var currentGridColor: String = "#00AACC"
    @Published var totalMultiplayerWins: Int = UserDefaults.standard.integer(forKey: "totalMPWins")
    @Published var multiplayerWon: Bool = false
    @Published var     showVictoryOverlay: Bool = false

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
        isInEvent = true
        eventWon = false
        activeEvent = event

        currentEventGridColor = event.gridColor  // NEU 🔥

        eventBossList = event.bosses.flatMap { $0.modelNames }
        eventBossIndex = 0

        loadEventBoss(modelID: eventBossList[0], data: event.bosses[0])
    }

    
    private func loadEventBoss(modelID: String, data: EventBoss) {

        let model = all.first(where: { $0.id == modelID })

        // 👉 RAID / MULTI-SCALING WERTE:
        let hp = data.hp.value(at: eventBossIndex)
        let coins = data.coins.value(at: eventBossIndex)
        let crystals = data.crystals.value(at: eventBossIndex)
        let exp = data.exp.value(at: eventBossIndex)

        // 👉 Hp setzen
        currentHP = hp + ArtefactInventoryManager.shared.bonusHP

        current = ModelConfig(
            id: modelID,
            modelName: model?.modelName ?? "spirit_fire", gridColor: "0099FF",
            scale: model?.scale ?? [1,1,1],
            position: model?.position ?? [0,0.2,0],
            rotation: model?.rotation ?? .init(x:0,y:0,z:0),
            camera: model?.camera ?? .init(position: [0,1.2,5], lookAt: [0,1,0]),
            light: model?.light ?? .init(intensity: 5000, position: [1,2,2]),
            facing: model?.facing ?? "right",
            hp: hp,
            next: nil,
            reward: .init(
                coins: coins,
                crystals: crystals,
                exp: exp
            )
        )
    }

    func startMultiplayer(_ event: MultiplayerEvent) {
        self.currentEvent = event
        self.currentGridColor = event.gridColor
        self.currentBosses = event.bosses
        self.isInMultiplayerMode = true
        
        loadMultiplayerBoss(index: 0)
        
        if multiplayerWon {
            showVictoryOverlay
        }
    }

    
    
    func loadMultiplayerBoss(index: Int = 0) {
        guard let event = currentEvent else { return }
        guard index < event.bosses.count else { return }

        let data = event.bosses[index]
        let modelID = data.modelNames.first ?? "default_id"
        let model = all.first(where: { $0.id == modelID })

        currentHP = data.hp.value(at: index) + ArtefactInventoryManager.shared.bonusHP

        current = ModelConfig(
            id: modelID,
            modelName: model?.modelName ?? "spirit_fire",
            gridColor: currentEvent?.gridColor ?? "#00AACC",
            scale: model?.scale ?? [1,1,1],
            position: model?.position ?? [0,0.2,0],
            rotation: model?.rotation ?? .init(x:0,y:0,z:0),
            camera: model?.camera ?? .init(position: [0,1.2,5], lookAt: [0,1,0]),
            light: model?.light ?? .init(intensity: 5000, position: [1,2,2]),
            facing: model?.facing ?? "right",
            hp: currentHP,
            next: nil,
            reward: .init(
                coins: data.coins.value(at: index),
                crystals: data.crystals.value(at: index),
                exp: data.exp.value(at: index)
            )
        )
    }

    func submitMultiplayerWin() {
        totalMultiplayerWins += 1
        UserDefaults.standard.set(totalMultiplayerWins, forKey: "totalMPWins")
        GCMPWins.submit(totalMultiplayerWins)
    }
    
    func showMultiplayerLeaderboard() {
        let viewController = GKGameCenterViewController(leaderboardID: "spirit_multiplayer_wins", playerScope: .global, timeScope: .allTime)
        viewController.gameCenterDelegate = GameCenterManager.shared as! any GKGameCenterControllerDelegate

        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(viewController, animated: true)
        }
    }
        
    private func handleDefeat() {
        // MULTI-BOSS HANDLING
        if isInEvent {
            if let event = activeEvent {
                // Mehr Bosse?
                if eventBossIndex + 1 < eventBossList.count {
                    eventBossIndex += 1
                    let nextID = eventBossList[eventBossIndex]

                    let bossData = event.bosses[0]
                    loadEventBoss(modelID: nextID, data: bossData)
                    return
                } else {
                    // Event abgeschlossen
                    isInEvent = false
                    eventWon = true   // -> EventGameView schließen
                    handleEventVictory()
                    return
                }
            } else {
                // Falls kein aktives Event vorhanden ist, beende Event-Sitzung defensiv
                isInEvent = false
                eventWon = true
                handleEventVictory()
                return
            }
        } else {
            // normaler Spirit → weiter zum nächsten Spirit
            giveReward()
            rollArtefactDrop()
            goToNext()
        }
    }

    
    func handleEventVictory() {
        EventShopManager.shared.spiritPoints += 10
        isInEvent = false
        currentEventGridColor = "#0066FF"   // Default oder Theme-Farbe
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
        
        currentMultiplayerIndex += 1

        if currentMultiplayerIndex < currentBosses.count {
            loadMultiplayerBoss(index: currentMultiplayerIndex)
        } else {
            // Multiplayer-Event abgeschlossen
            isInMultiplayerMode = false
            currentMultiplayerIndex = 0
            print("🏆 Multiplayer Event abgeschlossen!")
            // Optional: Siegesanzeige, Punkte etc.
        }

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

        let base = UpgradeManager.shared.tapDamage + ArtefactInventoryManager.shared.bonusTapDamage
        let damage = calculateDamage(base: base)

        if MatchManager.shared.isMatchActive {
            let attack = GameAction(
                type: .attack,
                playerID: GKLocalPlayer.local.playerID,
                value: damage
            )
            MatchManager.shared.sendActionData(attack)
        } else {
            currentHP = max(0, currentHP - damage)

            if currentHP == 0 {

                if isInEvent {
                    // WICHTIG: Multi-Boss Handling!
                    handleDefeat()
                } else {
                    // normaler Spirit
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
                let dropShards = art.dropShardsAmount   // z.B. 3–5
                ArtefactInventoryManager.shared.addShards(for: art, amount: dropShards)
                print("💎 Found \(dropShards) \(art.name) shards!")
                return
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
    }
}
