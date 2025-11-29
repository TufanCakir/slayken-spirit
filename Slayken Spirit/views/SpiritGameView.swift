import RealityKit
import SwiftUI

struct SpiritGameView: View {

    @EnvironmentObject private var game: SpiritGameController
    @EnvironmentObject private var musicManager: MusicManager
    @State private var activeSheet: ActiveSheet?
    @State private var gameButtons: [GameButton] = Bundle.main.loadGameButtons()

    enum ActiveSheet: Identifiable {
        case upgrade, artefacts
        var id: Int { hashValue }
    }

    var body: some View {
        ZStack {
            // --- Hintergrund & 3D Ansicht ---
            SpiritGridBackground(glowColor: Color(hex: game.current.gridColor))
            NormalSpiritView(config: game.current)
      

            // --- Tap Attack ---
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { game.tapAttack() }

            // --- HUD ---
            VStack {
                topHUD
                Spacer()
                bottomHUD
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .upgrade:
                UpgradeView().presentationDetents([.medium, .large])
            case .artefacts:
                ArtefactView()
            }
        }
        .onAppear {
            Task {
                await musicManager.forcePlaySong(index: 1)
            }
        }
    }
}

// MARK: - Normal 3D Ansicht

struct NormalSpiritView: View {
    let config: ModelConfig
    var body: some View {
        SpiritView(config: config)
    }
}

// MARK: - HUD (Top)

extension SpiritGameView {
    
    fileprivate var topHUD: some View {
        VStack(spacing: 14) {
            HStack {
                Spacer()
                HStack(spacing: 12) {
                    ForEach(gameButtons) { btn in
                        gameButton(btn)
                    }
                }
                .padding(.trailing, 110)
            }
            stageDisplay
            hpBar
        }
        .padding(.top, 0)
    }
    
    fileprivate var stageDisplay: some View {
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
    
    fileprivate var hpBar: some View {
        let maxHP = max(game.current.hp, 1)
        let percent = CGFloat(game.currentHP) / CGFloat(maxHP)
        
        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.1))
            
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 260 * percent)
                .animation(.easeInOut(duration: 0.3), value: game.currentHP)
            
            Text("\(game.currentHP) / \(maxHP)")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .heavy))
                .frame(maxWidth: .infinity)
        }
        .frame(width: 265, height: 26)
        .clipShape(Capsule())
    }
}


// MARK: - HUD (Bottom)

extension SpiritGameView {
    fileprivate var bottomHUD: some View {
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

    fileprivate func footerButton(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
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

// MARK: - Game Buttons

extension SpiritGameView {
    fileprivate func gameButton(_ btn: GameButton) -> some View {
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
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            : AnyShapeStyle(Color.white.opacity(0.1))
                    )
            )
            .overlay(
                Capsule().stroke(
                    isActive ? .cyan : .white.opacity(0.3),
                    lineWidth: 1.5
                )
            )
            .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
        }
    }

    fileprivate func handleGameButton(_ btn: GameButton) {
        switch btn.type {
        case "auto_battle":
            game.toggleAutoBattle()
        default:
            print("⚠️ Unbekannter Button-Typ:", btn.type)
        }
    }
}

// MARK: - Preview

#Preview {
    SpiritGameView()
        .environmentObject(SpiritGameController())
        .environmentObject(MusicManager())
}
