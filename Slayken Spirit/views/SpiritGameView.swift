import SwiftUI

struct SpiritGameView: View {

    @EnvironmentObject private var game: SpiritGameController

    @State private var isARMode = false
    @State private var activeSheet: ActiveSheet?
    @State private var gameButtons: [GameButton] = Bundle.main.loadGameButtons()

    enum ActiveSheet: Identifiable {
        case upgrade, artefacts
        var id: Int { hashValue }
    }

    var body: some View {
        ZStack {

            // ---------------------------------------------------
            // 🔥 1. MODE SWITCH (AR / 3D)
            // ---------------------------------------------------
            Group {
                if isARMode {
                    ARSpiritBattleView(config: game.current)
                        .ignoresSafeArea()
                } else {
                    SpiritSceneView(config: game.current)
                }
            }
            
            // 2. TAP-LAYER FÜR ANGRIFFE
             Color.clear
                 .contentShape(Rectangle())
                 .onTapGesture {
                     game.tapAttack()
                 }

            // ---------------------------------------------------
            // 🔥 2. HUD
            // ---------------------------------------------------
            VStack {
                topHUD
                Spacer()
                bottomHUD
            }
            .padding(.horizontal)
            .padding(.top, 25)

            // ---------------------------------------------------
            // 🔥 3. AR TOGGLE BUTTON
            // ---------------------------------------------------
            VStack {
                HStack {
                    Spacer()
                    ARSwitch
                }
                Spacer()
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .upgrade:
                UpgradeView().presentationDetents([ .medium, .large ])
            case .artefacts:
                ArtefactView()
            }
        }
    }
}

struct SpiritSceneView: View {
    let config: ModelConfig
    var body: some View {
        ZStack {
            SpiritGridBackground(glowColor: Color(hex: config.gridColor))
            NormalSpiritView(config: config)
        }
        .ignoresSafeArea()
    }
}

struct NormalSpiritView: View {
    let config: ModelConfig

    var body: some View {
        SpiritView(config: config)
    }
}


private extension SpiritGameView {

    var topHUD: some View {
        VStack(spacing: 14) {

            // Buttons oben rechts
            HStack {
                Spacer()
                HStack(spacing: 12) {
                    ForEach(gameButtons) { btn in
                        gameButton(btn)
                    }
                }
                .padding(.trailing, 89)   // Abstand vom rechten Rand
            }
            .padding(.top, 10)            // Abstand nach oben
            stageDisplay
            hpBar
            }
        }
    }


private extension SpiritGameView {
    var stageDisplay: some View {
        Text("Stage \(game.stage)")
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: [.cyan, .blue, .black],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1.5)
            )
    }
}


private extension SpiritGameView {
    var hpBar: some View {

        let maxHP = max(game.current.hp, 1)
        let percent = CGFloat(game.currentHP) / CGFloat(maxHP)

        return ZStack(alignment: .leading) {

            Capsule()
                .fill(Color.white.opacity(0.12))

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 265 * percent)
                .animation(.easeInOut(duration: 0.25), value: game.currentHP)

            Text("\(game.currentHP) / \(maxHP)")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
        }
        .frame(width: 265, height: 26)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(.white.opacity(0.7), lineWidth: 1.5)
        )
    }
}

private extension SpiritGameView {
    var bottomHUD: some View {
        HStack(spacing: 22) {
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

private extension SpiritGameView {

    func gameButton(_ btn: GameButton) -> some View {
        let isActive = (btn.type == "auto_battle" && game.isAutoBattle)

        return Button {
            handleGameButton(btn)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: btn.icon)
                    .font(.system(size: 20, weight: .heavy))

                Text(btn.title)
                    .font(.system(size: 18, weight: .heavy))
            }
           
            .foregroundColor(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        isActive
                        ? AnyShapeStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.white.opacity(0.1))
                    )
            )
            .overlay(
                Capsule().stroke(isActive ? .cyan : .white.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
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

private extension SpiritGameView {
    var ARSwitch: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                isARMode.toggle()
            }
        } label: {
            Image(systemName: isARMode ? "arkit" : "arkit.badge.xmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.cyan)
                .padding(14)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .cyan.opacity(0.8), radius: 8)
        }
        .padding()
    }
}

private extension SpiritGameView {
    func handleGameButton(_ btn: GameButton) {
        switch btn.type {
        case "auto_battle":
            // Toggle auto-battle mode on the game controller
            game.isAutoBattle.toggle()
        case "restart":
            // Prefer a controller API if available to reset state
            if let restart = (game as AnyObject) as? (any NSObjectProtocol), restart.responds(to: Selector(("restart"))) {
                // If the controller implements a @objc restart method
                _ = (game as AnyObject).perform(Selector(("restart")))
            } else {
                // Post an intent/notification that the controller can observe to perform restart safely
                NotificationCenter.default.post(name: Notification.Name("SpiritGameController.requestRestart"), object: nil)
            }
        case "next_stage":
            // Ask controller to advance stage (avoids direct mutation when setter is private)
            if let advance = (game as AnyObject) as? (any NSObjectProtocol), advance.responds(to: Selector(("nextStage"))) {
                _ = (game as AnyObject).perform(Selector(("nextStage")))
            } else {
                NotificationCenter.default.post(name: Notification.Name("SpiritGameController.requestNextStage"), object: nil)
            }
        case "prev_stage":
            // Ask controller to go to previous stage
            if let back = (game as AnyObject) as? (any NSObjectProtocol), back.responds(to: Selector(("previousStage"))) {
                _ = (game as AnyObject).perform(Selector(("previousStage")))
            } else {
                NotificationCenter.default.post(name: Notification.Name("SpiritGameController.requestPreviousStage"), object: nil)
            }
        case "open_upgrade":
            activeSheet = .upgrade
        case "open_artefacts":
            activeSheet = .artefacts
        default:
            // Unknown type: no-op for now
            break
        }
    }
}



#Preview {
    SpiritGameView()
        .environmentObject(SpiritGameController())
}

