import SwiftUI

struct EventGameView: View {

    @EnvironmentObject private var game: SpiritGameController
    @Environment(\.dismiss) private var dismiss

    @State private var activeSheet: ActiveSheet?

    enum ActiveSheet: Identifiable {
        case upgrade
        case artefacts

        var id: String {
            switch self {
            case .upgrade: return "upgrade"
            case .artefacts: return "artefacts"
            }
        }
    }

    var body: some View {
        ZStack {
            SpiritGridBackground()

       
            // 3D SPIRIT
            SpiritView(config: game.current)
                .id(game.current.id + "_event")
                .onTapGesture { game.tapAttack() }
         
            VStack {
                topHUD
                Spacer()
                bottomHUD
                bottomHUDButton
            }
        }
        .onChange(of: game.eventWon) { oldValue, newValue in
            if newValue {
                dismiss()
                game.eventWon = false   // ← RESET
            }
        }

        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .upgrade:
                UpgradeView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)

            case .artefacts:
                ArtefactView()
            }
        }
    }
}

private extension EventGameView {
    
    var bottomHUD: some View {
        HStack(spacing: 20) {
            footerButton(icon: "arrow.up.circle.fill", title: "Upgrade") {
                activeSheet = .upgrade
            }
            
            footerButton(icon: "sparkles", title: "Artefakte") {
                activeSheet = .artefacts
            }
        }
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    func footerButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.subheadline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.white, lineWidth: 1)
            )
        }
    }
}

private extension EventGameView {

    func gameButton(_ btn: EventGameButton) -> some View {

        let isActive: Bool = {
            switch btn.type {
            case "auto_battle": return game.isAutoBattle
            default: return false
            }
        }()

        return Button {
            handleGameButton(btn)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: btn.icon)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                Text(btn.title)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 5)
            .background {
                ZStack {
                    // Material layer behind for glow/depth when inactive
                    if !isActive {
                        Capsule()
                            .fill(.blue)
                    }
                    // Foreground capsule fill uses consistent ShapeStyle types
                    Capsule()
                        .fill(
                            isActive
                            ? AnyShapeStyle(LinearGradient(colors: [.red, .black, .red], startPoint: .top, endPoint: .bottom))
                            : AnyShapeStyle(Color.white.opacity(0.08))
                        )
                }
            }
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.cyan.opacity(0.8) : .white.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.5), radius: 6, y: 3)

            .animation(.easeInOut(duration: 0.25), value: isActive)
        }
    }
}

private extension EventGameView {
    
    var topHUD: some View {
        VStack(spacing: 14) {
            // 👉 Buttons oben rechts
            HStack {
                Spacer()
                HStack(spacing: 12) {
                    ForEach(gameButtons) { btn in
                        gameButton(btn)
                    }
                }
                .padding(.trailing, 130)
            }
            
            
            // ⭐ Spirit Points
            Text("Spirit Points: \(EventShopManager.shared.spiritPoints)")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        
        .padding(.horizontal, 30)
        .padding(.vertical, 6)
        .background(.blue)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.5), radius: 6, y: 3)
    
            
            // 🔥 HP Balken (Boss HP)
            hpBar
        }
        .padding(.top, 20)
    }
}
private extension EventGameView {

    var hpBar: some View {

        let maxHP = max(game.current.hp, 1)
        let percent = CGFloat(game.currentHP) / CGFloat(maxHP)

        return ZStack(alignment: .leading) {

            Capsule()
                .fill(LinearGradient(colors:                         [.blue, .black, .blue],

                                     startPoint: .leading,
                                     endPoint: .trailing))
                .frame(maxWidth: 260 * percent)
                .animation(.easeInOut(duration: 0.3), value: game.currentHP)

            Capsule()
                .stroke(.white, lineWidth: 2)

            HStack {
                Spacer()
                Text("\(game.currentHP) / \(maxHP)")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
            }
        }
        .frame(width: 265, height: 25)
    }
}

private extension EventGameView {

    func handleGameButton(_ btn: EventGameButton) {
        switch btn.type {
        case "auto_battle":
            game.toggleAutoBattle()

        default:
            print("⚠️ Unbekannter Button-Typ:", btn.type)
        }
    }
}


private extension EventGameView {

    var bottomHUDButton: some View {
        Button {
            game.isInEvent = false
        } label: {
            Text("Leave Event")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }
}


private struct EventGameButton: Identifiable {
    let id = UUID()
    let type: String
    let icon: String
    let title: String
}

private let gameButtons: [EventGameButton] = [
    EventGameButton(type: "auto_battle", icon: "bolt.fill", title: "Auto"),
]


#Preview {
    EventGameView()
        .environmentObject(SpiritGameController())
}
