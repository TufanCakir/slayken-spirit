import Foundation
import SwiftUI
internal import Combine

@MainActor
final class EventShopManager: ObservableObject {
    
    static let shared = EventShopManager()
    
    @Published private(set) var items: [EventShopItem] = []
    @Published private(set) var inventory: [EventShopItem] = []
    
    @Published var spiritPoints: Int = 0
    
    private let saveKey = "eventShopInventory"
    
    private init() {
        loadShop()
        loadInventory()
    }
    
    
    func activate(_ item: EventShopItem) {
        guard let index = inventory.firstIndex(where: { $0.id == item.id }) else { return }
        inventory[index].isActive = true
        applyBonus(inventory[index])
        saveInventory()
        objectWillChange.send()
    }

    
    // MARK: - Shop Daten laden
    private func loadShop() {
        do {
            items = try Bundle.main.decodeSafe("eventShop.json")
        } catch {
            print("❌ Fehler beim Laden von eventShop.json:", error)
            items = []
        }
    }
    
    
    // MARK: Inventory speichern/lesen
    private func saveInventory() {
        if let encoded = try? JSONEncoder().encode(inventory) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadInventory() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([EventShopItem].self, from: data) else {
            return
        }
        inventory = decoded
    }
    
    
    // MARK: - Kaufen / Stack erhöhen
    func buyItem(_ item: EventShopItem) -> Bool {
        
        guard spiritPoints >= item.price else {
            print("❌ Nicht genug Spirit Points!")
            return false
        }
        
        spiritPoints -= item.price
        
        // Prüfen ob Item bereits im Inventory existiert
        if let index = inventory.firstIndex(where: { $0.id == item.id }) {
            
            // Stack +1
            inventory[index].stack += 1
            
            // Aktivieren möglich?
            if inventory[index].stack >= inventory[index].required {
                inventory[index].isActive = true
                applyBonus(inventory[index])
            }
            
        } else {
            // Neues Item ins Inventory
            var newItem = item
            newItem.stack = 1
            
            // Aktivieren möglich?
            if newItem.stack >= newItem.required {
                newItem.isActive = true
                applyBonus(newItem)
            }
            
            inventory.append(newItem)
        }
        
        saveInventory()
        return true
    }
    
    
    // MARK: - Aktiv prüfen
    func isActive(_ item: EventShopItem) -> Bool {
        inventory.first(where: { $0.id == item.id })?.isActive ?? false
    }
    
    func currentStack(for item: EventShopItem) -> Int {
        inventory.first(where: { $0.id == item.id })?.stack ?? 0
    }
    
    
    // MARK: - Bonus anwenden
    private func applyBonus(_ item: EventShopItem) {
        
        guard item.isActive else { return }   // Bonus nur wenn aktiv
        
        switch item.type {
        case "tapDamage":
            UpgradeManager.shared.increaseTapDamage(by: 5)  // Beispielwert
            
        case "expBoost":
            UpgradeManager.shared.increaseExpBoost(by: 10)
            
        case "lootBoost":
            UpgradeManager.shared.increaseLootBoost(by: 7)
            
        case "coinBoost":
            UpgradeManager.shared.increaseCoinBoost(by: 15)
            
        default:
            break
        }
    }
    
    
    // MARK: - Reset
    func reset() {
        spiritPoints = 0
        inventory.removeAll()
        UserDefaults.standard.removeObject(forKey: saveKey)
        print("🛒 EventShop reset!")
    }
}
