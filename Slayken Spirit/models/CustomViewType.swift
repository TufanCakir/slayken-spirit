import Foundation

enum CustomViewType: String, Identifiable, CaseIterable, Codable {
    case spiritGameView, eventGameView, eventButton, homeView
    case settingsView, questView, giftView, dailyLoginView
    case hallOfFameView, spiritListView, exchangeView, eventShopInventoryView
    case multiplayerView
    case stageText, customText, emptySpacer

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .spiritGameView: return "Spirit Game"
        case .eventGameView: return "Event Game"
        case .eventButton: return "Event Button"
        case .homeView: return "Home View"
        case .settingsView: return "Settings"
        case .questView: return "Quests"
        case .giftView: return "Gifts"
        case .dailyLoginView: return "Daily Bonus"
        case .hallOfFameView: return "Hall of Fame"
        case .spiritListView: return "Spirits"
        case .exchangeView: return "Exchange"
        case .eventShopInventoryView: return "Inventory"
        case .multiplayerView: return "Multiplayer"
        case .stageText: return "Stage Text"
        case .customText: return "Custom Text"
        case .emptySpacer: return "Spacer"
        }
    }
}
