import SwiftUI

struct EventView: View {

    @StateObject private var game = SpiritGameController()

    @State private var activeSheet: ActiveSheet?
    @State private var gameButtons: [GameButton] = Bundle.main.loadGameButtons()

    enum ActiveSheet: Identifiable {
        case upgrade
        case artefacts
        case eventSelect

        var id: Int { hashValue }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // 3D Szene
            SpiritView(config: game.current)
                .id(game.current.id)
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

            case .eventSelect:
                EventSelectionView(game: game)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        // 🔥 Automatische Event-Auswahl beim Öffnen!
        .onAppear {
            activeSheet = .eventSelect
        }
    }
}

//
// MARK: - TOP HUD
//
private extension EventView {

    var topHUD: some View {
        VStack(spacing: 14) {

            // RIGHT BUTTONS (AutoBattle, … + Event Button)
            HStack {
                Spacer()
                HStack(spacing: 12) {

                    ForEach(gameButtons) { btn in
                        gameButton(btn)
                    }

                    // EVENT SELECT BUTTON
                    Button {
                        activeSheet = .eventSelect
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.headline)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
            }

            stageDisplay
            hpBar

        }
        .padding(.top, 20)
    }
}

//
// MARK: - STAGE
//
private extension EventView {
    var stageDisplay: some View {
        Text("Stage \(game.stage)")
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.5), radius: 6, y: 3)
    }
}

//
// MARK: - BOTTOM HUD
//
private extension EventView {

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

//
// MARK: - GAME BUTTON (AutoBattle etc.)
//
private extension EventView {

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
                Image(systemName: btn.icon).font(.headline)
                Text(btn.title).font(.subheadline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 10)
            .background {
                ZStack {
                    if !isActive {
                        Capsule().fill(.ultraThinMaterial)
                    }
                    Capsule()
                        .fill(
                            isActive
                            ? AnyShapeStyle(LinearGradient(colors: [.blue, .black, .blue], startPoint: .top, endPoint: .bottom))
                            : AnyShapeStyle(Color.white.opacity(0.08))
                        )
                }
            }
            .overlay(
                Capsule().stroke(isActive ? Color.cyan.opacity(0.8) : .white.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: isActive ? Color.cyan.opacity(0.7) : .clear, radius: 6)
            .animation(.easeInOut(duration: 0.25), value: isActive)
        }
    }
}

//
// MARK: - GAME BUTTON HANDLING
//
private extension EventView {

    func handleGameButton(_ btn: GameButton) {
        switch btn.type {

        case "auto_battle":
            game.toggleAutoBattle()

        default:
            print("⚠️ Unbekannter Button-Typ:", btn.type)
        }
    }
}

//
// MARK: - FOOTER BUTTON
//
private extension EventView {

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

//
// MARK: - HP BAR
//
private extension EventView {

    var hpBar: some View {

        let maxHP = max(game.current.hp, 1)
        let percent = CGFloat(game.currentHP) / CGFloat(maxHP)

        return ZStack(alignment: .leading) {

            Capsule()
                .fill(LinearGradient(colors: [.blue, .black, .blue],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(maxWidth: 260 * percent)
                .animation(.easeInOut(duration: 0.3), value: game.currentHP)

            Capsule().stroke(.white, lineWidth: 2)

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

//
// MARK: - EVENT SELECTION VIEW
//
struct EventSelectionView: View {

    let game: SpiritGameController

    var body: some View {
        NavigationStack {
            List(game.events) { ev in
                Button {
                    game.selectEvent(ev)
                } label: {
                    HStack {
                        Image(systemName: ev.icon)
                            .foregroundColor(.white)
                        Text(ev.name)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Events")
            .scrollContentBackground(.hidden)
            .background(Color.black)
        }
    }
}

#Preview {
    EventView()
}
