//
//  SpiritGameController.swift
//  Slayken Spirit
//

internal import Combine
import Foundation

@MainActor
final class SpiritGameController: ObservableObject {

    // MARK: - Published: UI States
    @Published private(set) var current: ModelConfig
    @Published private(set) var currentHP: Int
    @Published private(set) var stage: Int = {
        // Load stage from UserDefaults
        let saved = UserDefaults.standard.integer(forKey: "savedStage")
        return max(saved, 1)
    }()

    @Published private(set) var point: Int = {
        let saved = UserDefaults.standard.integer(forKey: "savedPoint")
        return max(saved, 1)
    }()

    @Published var isAutoBattle: Bool = false

    // MARK: - Active Event
    private var activeEvent: GameEvent?
    @Published var isInEvent: Bool = false
    @Published var eventWon: Bool = false
    @Published var eventBossList: [String] = []
    @Published var eventBossIndex: Int = 0
    @Published var currentEventGridColor: String = "#00AACC"

    // MARK: - Stats
    @Published var totalKills: Int = UserDefaults.standard.integer(
        forKey: "totalKills"
    )
    @Published var totalQuests: Int = UserDefaults.standard.integer(
        forKey: "totalQuests"
    )
    @Published var playtimeMinutes: Int = UserDefaults.standard.integer(
        forKey: "playtimeMinutes"
    )

    private var autoBattleTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

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
    }

    private func saveStats() {
        UserDefaults.standard.set(totalKills, forKey: "totalKills")
        UserDefaults.standard.set(totalQuests, forKey: "totalQuests")
        UserDefaults.standard.set(playtimeMinutes, forKey: "playtimeMinutes")
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

        currentEventGridColor = event.gridColor

        eventBossList = event.bosses.flatMap { $0.modelNames }
        eventBossIndex = 0

        loadEventBoss(modelID: eventBossList[0], data: event.bosses[0])
    }

    private func loadEventBoss(modelID: String, data: EventBoss) {
        let model = all.first(where: { $0.id == modelID })

        let hp = data.hp.value(at: eventBossIndex)
        let coins = data.coins.value(at: eventBossIndex)
        let crystals = data.crystals.value(at: eventBossIndex)
        let exp = data.exp.value(at: eventBossIndex)

        currentHP = hp + ArtefactInventoryManager.shared.bonusHP

        current = ModelConfig(
            id: modelID,
            modelName: model?.modelName ?? "spirit_fire",
            gridColor: "0099FF",
            scale: model?.scale ?? [1, 1, 1],
            position: model?.position ?? [0, 0.2, 0],
            rotation: model?.rotation ?? .init(x: 0, y: 0, z: 0),
            camera: model?.camera
                ?? .init(position: [0, 1.2, 5], lookAt: [0, 1, 0]),
            light: model?.light ?? .init(intensity: 5000, position: [1, 2, 2]),
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
    
    func resetStage() {
        stage = 1
        UserDefaults.standard.set(1, forKey: "savedStage")
    }


    // MARK: - Player Tap
    func tapAttack() {
        guard currentHP > 0 else { return }

        let base =
            UpgradeManager.shared.tapDamage
            + ArtefactInventoryManager.shared.bonusTapDamage
        let damage = calculateDamage(base: base)

        currentHP = max(0, currentHP - damage)

        if currentHP == 0 {
            handleDefeat()
        }
    }

    private func handleDefeat() {

        // 1. ARTEFAKT-DROP IMMER
        rollArtefactDrop()

        // 2. EVENT
        if isInEvent {
            if let event = activeEvent {
                if eventBossIndex + 1 < eventBossList.count {
                    eventBossIndex += 1
                    let nextID = eventBossList[eventBossIndex]
                    let bossData = event.bosses[0]
                    loadEventBoss(modelID: nextID, data: bossData)
                    return
                } else {
                    isInEvent = false
                    eventWon = true
                    handleEventVictory()
                    return
                }
            }
        }

        // 3. NORMALER MODUS
        giveReward()
        goToNext()
    }

    func handleEventVictory() {
        EventShopManager.shared.spiritPoints += 10
        isInEvent = false
        currentEventGridColor = "#0066FF"
        eventWon = true
    }

    private func calculateDamage(base: Int) -> Int {
        let critChance = ArtefactInventoryManager.shared.bonusCritChance
        let critDamage = ArtefactInventoryManager.shared.bonusCritDamage
        let roll = Double.random(in: 0...100)

        if roll <= critChance {
            return Int(Double(base) * (1 + critDamage / 100.0))
        }
        return base
    }

    func toggleAutoBattle() {
        isAutoBattle.toggle()
        isAutoBattle ? startAutoBattle() : stopAutoBattle()
    }

    private func startAutoBattle() {
        stopAutoBattle()
        let speedPercent = ArtefactInventoryManager.shared.bonusAttackSpeed
        let interval = max(0.05, 0.18 * (1 - speedPercent / 100))

        autoBattleTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
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

    private func rollArtefactDrop() {
        let total = ArtefactInventoryManager.shared.total
        GCArtefacts.submit(total)
        GameCenterRewardService.shared.rewardForArtefacts(total)

        let artefacts = Bundle.main.loadArtefacts("artefacts")
        let lootBoost = ArtefactInventoryManager.shared.bonusLootBoost

        for art in artefacts {
            var chance = art.dropChance + (lootBoost / 100.0)
            chance = min(chance, 0.95)
            if Double.random(in: 0...1) <= chance {
                let dropShards = art.dropShardsAmount
                ArtefactInventoryManager.shared.addShards(
                    for: art,
                    amount: dropShards
                )
                print("💎 Found \(dropShards) \(art.name) shards!")
                return
            }
        }
    }

    private func giveReward() {
        guard let reward = current.reward else { return }

        let expBonus = ArtefactInventoryManager.shared.bonusExp
        let coinBonus = ArtefactInventoryManager.shared.bonusCoins

        CoinManager.shared.addCoins(reward.coins + coinBonus)
        CrystalManager.shared.addCrystals(reward.crystals)
        AccountLevelManager.shared.addExp(reward.exp + expBonus)
    }

    private func goToNext() {
        guard let idx = all.firstIndex(where: { $0.id == current.id }) else {
            return
        }

        let nextIndex = (idx + 1) % all.count
        let next = all[nextIndex]

        stage += 1
        point += 1
        UserDefaults.standard.set(stage, forKey: "savedStage")

        GCKills.submit(totalKills)
        GameCenterRewardService.shared.rewardForKills(totalKills)

        GCQuests.submit(totalQuests)
        GameCenterRewardService.shared.rewardForQuests(totalQuests)

        GCPlaytime.submit(playtimeMinutes)
        GameCenterRewardService.shared.rewardForPlaytime(playtimeMinutes)

        GCHighestStage.submit(stage)
        GameCenterRewardService.shared.rewardForStage(stage)

        saveStats()

        current = next
        recalculateHP()
    }
}
