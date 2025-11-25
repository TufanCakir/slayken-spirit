import SwiftUI

struct SpiritGameView: View {

    @EnvironmentObject private var game: SpiritGameController

    @State private var activeSheet: ActiveSheet?
    @State private var gameButtons: [GameButton] = Bundle.main.loadGameButtons()
    enum ActiveSheet: Identifiable {
        case upgrade
        case artefacts

        var id: Int { hashValue }
    }

    var body: some View {
        ZStack {
            SpiritGridBackground()



            SpiritView(config: game.current)
                .id(game.current.id + (game.isInEvent ? "_event" : "_normal"))
                .onTapGesture { game.tapAttack() }

            VStack {
                topHUD
                Spacer()
                bottomHUD
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

struct SpiritBackgroundView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
    }
}



private extension SpiritGameView {
    

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
                    .padding(.trailing, 100)
                }

                // 👉 Stage Anzeige
                stageDisplay
                // 👉 Points Anzeige

                // 👉 HP Bar
                hpBar
            }
            .padding(.top, 20)
        }
    }



private extension SpiritGameView {

    var stageDisplay: some View {
        
        HStack(spacing: 8) {

            /*Image(systemName: "squares.leading.rectangle")   // <- Wähle dein Symbol!
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.yellow)*/

        Text("Stage \(game.stage)")
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 6)
        .background(.blue)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.5), radius: 6, y: 3)
    }
}



private extension SpiritGameView {
    
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
}



extension SpiritGameController {
    func activity(_ action: (SpiritGameController) -> Void) {
        action(self)
    }
}


private extension SpiritGameView {

    func gameButton(_ btn: GameButton) -> some View {

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
            .padding(.vertical, 6)
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
                            ? AnyShapeStyle(LinearGradient(colors: [.blue, .black, .blue], startPoint: .top, endPoint: .bottom))
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




private extension SpiritGameView {

    func handleGameButton(_ btn: GameButton) {
        switch btn.type {
        case "auto_battle":
            game.toggleAutoBattle()

        default:
            print("⚠️ Unbekannter Button-Typ:", btn.type)
        }
    }
}




private extension SpiritGameView {



        func footerButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: icon).font(.title2)
                    Text(title).font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
        }
    }




// MARK: - HP BAR
private extension SpiritGameView {

    var hpBar: some View {

        let maxHP = max(game.current.hp, 1)
        let percent = CGFloat(game.currentHP) / CGFloat(maxHP)

        return ZStack(alignment: .leading) {

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.blue, .black, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: 260 * percent)
                .animation(.easeInOut(duration: 0.3), value: game.currentHP)

            Capsule()
                .stroke(.white, lineWidth: 2)

            HStack {
                Spacer()
                Text("\(game.currentHP) / \(maxHP)")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .frame(width: 265, height: 25)
    }
}


#Preview {
    SpiritGameView()
        .environmentObject(SpiritGameController())
}
