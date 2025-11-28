import SwiftUI

struct EventGameView: View {

    @EnvironmentObject private var game: SpiritGameController
    @Environment(\.dismiss) private var dismiss

    @State private var activeSheet: ActiveSheet?

    enum ActiveSheet: Identifiable {
        case upgrade, artefacts
        var id: String { "\(self)" }
    }

    var body: some View {
        ZStack {

            // ---------------------------------------------------
            // 🔥 1. RENDER (nur 3D Ansicht)
            // ---------------------------------------------------
            renderLayer

            // ---------------------------------------------------
            // 🔥 2. TAP ATTACK
            // ---------------------------------------------------
            attackLayer

            // ---------------------------------------------------
            // 🔥 3. HUD (Top + Bottom)
            // ---------------------------------------------------
            hudLayer
        }

        // → Event abgeschlossen → zurück
        .onChange(of: game.eventWon) { _, won in
            if won {
                dismiss()
                game.eventWon = false
            }
        }

        // Bottom Sheets
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .upgrade:
                UpgradeView()
                    .presentationDetents([.medium, .large])
            case .artefacts:
                ArtefactView()
            }
        }
    }
}

// MARK: - RENDER

extension EventGameView {
    fileprivate var renderLayer: some View {
        ZStack {
            SpiritGridBackground(
                glowColor: Color(hex: game.currentEventGridColor)
            )
            SpiritView(config: game.current)
                .id(game.current.id + "_event")
        }
        .ignoresSafeArea()
    }
}

// MARK: - TAP

extension EventGameView {
    fileprivate var attackLayer: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture { game.tapAttack() }
            .ignoresSafeArea()
    }
}

// MARK: - HUD

extension EventGameView {
    fileprivate var hudLayer: some View {
        VStack {
            topHUD
            Spacer()
            bottomHUD
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }

    fileprivate var topHUD: some View {
        VStack(spacing: 14) {

            // Buttons oben rechts
            HStack {
                Spacer()
                HStack(spacing: 12) {
                    ForEach(eventButtons) { btn in
                        gameButton(btn)
                    }
                }
                .padding(.trailing, 120)
            }

            // Spirit Points
            Text("Spirit Points: \(EventShopManager.shared.spiritPoints)")
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
                .shadow(color: .black.opacity(0.5), radius: 6, y: 3)

            // HP-Bar
            hpBar
        }
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

    @ViewBuilder
    fileprivate func footerButton(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.headline)
                Text(title).font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1)
            )
        }
    }
}

// MARK: - Buttons

extension EventGameView {
    fileprivate func gameButton(_ btn: EventGameButton) -> some View {
        let active = (btn.type == "auto_battle" && game.isAutoBattle)

        return Button {
            handleGameButton(btn)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: btn.icon)
                    .font(.system(size: 20, weight: .heavy))
                Text(btn.title)
                    .font(.system(size: 20, weight: .heavy))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(
                    active
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
                    active ? .cyan : .white.opacity(0.3),
                    lineWidth: 1.5
                )
            )
            .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
        }
    }

    fileprivate func handleGameButton(_ btn: EventGameButton) {
        switch btn.type {
        case "auto_battle":
            game.toggleAutoBattle()
        default:
            print("⚠️ Unbekannter Button:", btn.type)
        }
    }
}

// MARK: - Button Model

private struct EventGameButton: Identifiable {
    let id = UUID()
    let type: String
    let icon: String
    let title: String
}

private let eventButtons: [EventGameButton] = [
    EventGameButton(type: "auto_battle", icon: "bolt.fill", title: "Auto")
]

// MARK: - Preview

#Preview {
    EventGameView()
        .environmentObject(SpiritGameController())
}
