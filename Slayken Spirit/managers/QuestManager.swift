import Foundation
internal import Combine

final class QuestManager: ObservableObject {

    static let shared = QuestManager()
    private init() {
        load()
    }

    private let storageKey = "completedQuests"

    @Published var completed: Set<String> = []

    private func load() {
        if let saved = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            completed = Set(saved)
        }
    }

    func save() {
        UserDefaults.standard.set(Array(completed), forKey: storageKey)
    }

    // Fortschritt berechnen
    func progress(for quest: Quest) -> Int {
        switch quest.type {

        case "stage":
            return UserDefaults.standard.integer(forKey: "savedStage")

        case "kills":
            return UserDefaults.standard.integer(forKey: "totalKills")

        case "artefacts":
            return ArtefactInventoryManager.shared.owned.count

        case "playtime":
            return UserDefaults.standard.integer(forKey: "playtimeMinutes")

        case "special":
            return 1

        default:
            return 0
        }
    }

    // Quest abschließen
    func claim(_ quest: Quest) {
        guard !completed.contains(quest.id) else { return }

        RewardManager.shared.give(.combine([
            .coins(quest.reward.coins),
            .crystals(quest.reward.crystals),
            .exp(quest.reward.exp),
            quest.reward.artefact != nil ? .artefact(quest.reward.artefact!) : nil
        ].compactMap { $0 }))

        completed.insert(quest.id)
        save()

        objectWillChange.send()   // <- 🟢 zwingt UI zu aktualisieren
    }

    func reset() {
        completed.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
        ObjectWillChangePublisher().send()

        print("🔄 QuestManager reset! Alle Quests zurückgesetzt.")
    }
    
    // Lokalisierung
    func localizedTitle(for quest: Quest) -> String {
        Locale.current.language.languageCode?.identifier == "de"
        ? quest.name_de
        : quest.name_en
    }

    func localizedDescription(for quest: Quest) -> String {
        Locale.current.language.languageCode?.identifier == "de"
        ? quest.desc_de
        : quest.desc_en
    }
}
