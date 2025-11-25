import Foundation
import SwiftUI
internal import Combine

@MainActor
final class EventShopManager: ObservableObject {
    
    static let shared = EventShopManager()
    
    @Published private(set) var items: [EventShopItem] = []
    @Published private(set) var inventory: [EventShopItem] = []
    
    @Published var spiritPoints: Int = 0
    
    private init() {
        loadShop()
        loadInventory()
    }
    
    // MARK: Shop Daten laden
    private func loadShop() {
        do {
            items = try Bundle.main.decodeSafe("eventShop.json")
        } catch {
            print("❌ Fehler beim Laden von eventShop.json:", error)
        }
    }
    
    // MARK: Inventory speichern/lesen
    private func saveInventory() {
        if let encoded = try? JSONEncoder().encode(inventory) {
            UserDefaults.standard.set(encoded, forKey: "eventShopInventory")
        }
    }
    
    private func loadInventory() {
        if let data = UserDefaults.standard.data(forKey: "eventShopInventory"),
           let decoded = try? JSONDecoder().decode([EventShopItem].self, from: data) {
            inventory = decoded
        }
    }
    
    // MARK: Kaufen
    func buyItem(_ item: EventShopItem) -> Bool {
        
        guard spiritPoints >= item.price else {
            print("❌ Nicht genug Spirit Points!")
            return false
        }
        
        // SP abziehen
        spiritPoints -= item.price
        
        // In Inventar
        inventory.append(item)
        saveInventory()
        
        // Werte anwenden
        applyBonus(item)
        
        return true
    }
    
    // MARK: - Reset
    func reset() {
        // Alles zurücksetzen
        spiritPoints = 0
        inventory.removeAll()
        
        // Speicher löschen
        UserDefaults.standard.removeObject(forKey: "eventShopInventory")
        
        print("🛒 EventShop reset!")
    }

    func hasBought(_ item: EventShopItem) -> Bool {
        return inventory.contains(where: { $0.id == item.id })
    }

    private func applyBonus(_ item: EventShopItem) {
        
        switch item.type {
            
        case "tapDamage":
            UpgradeManager.shared.increaseTapDamage(by: item.value)
            
        case "expBoost":
            UpgradeManager.shared.increaseExpBoost(by: item.value)
            
        case "lootBoost":
            UpgradeManager.shared.increaseLootBoost(by: Double(item.value))
            
        case "coinBoost":
            UpgradeManager.shared.increaseCoinBoost(by: item.value)
            
        default:
            break
        }
    }
}
