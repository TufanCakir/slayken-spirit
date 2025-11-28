import SwiftUI
import RealityKit // Notwendig für die ARViewRepresentable

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

            // --- 1. MODE SWITCH (AR / 3D) ---
            if isARMode {
                ARViewRepresentable() // Die AR-Ansicht
                    .ignoresSafeArea()
            } else {
                SpiritGridBackground(glowColor: Color(hex: game.current.gridColor))
                NormalSpiritView(config: game.current)
            }

            // --- 2. TAP ATTACK LAYER ---
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { game.tapAttack() }

            // --- 3. HUD ---
            VStack {
                topHUD
                Spacer()
                bottomHUD
            }

            // --- 4. AR Toggle Button ---
            VStack {
                HStack {
                    Spacer()
                    arToggleLayer
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

// ------------------------------------------------------------------
// MARK: - ZUSÄTZLICHE VIEWS (Wiederhergestellt)
// ------------------------------------------------------------------

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

// ------------------------------------------------------------------
// MARK: - PRIVATE EXTENSIONS (Wiederhergestellt)
// ------------------------------------------------------------------

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
                .padding(.trailing, 110)
            }
            .padding(.top, 0)
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

    var arToggleLayer: some View {
        VStack {
            HStack {
                Spacer()
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
            Spacer()
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


#Preview {
    SpiritGameView()
        .environmentObject(SpiritGameController())
}
