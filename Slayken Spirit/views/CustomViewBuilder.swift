import SwiftUI

struct CustomViewBuilder: View {
    @State private var viewItems: [CustomViewType] = []
    @State private var showAddMenu = false
    @State private var editMode = false
    @State private var selectedIndices: Set<Int> = []

    private let saveKey = "SavedViewItems"

    var body: some View {
        VStack {
            HStack {
                Button(editMode ? "Abbrechen" : "Bearbeiten") {
                    editMode.toggle()
                    selectedIndices.removeAll()
                }
                .foregroundColor(.white)

                Spacer()

                if editMode && !selectedIndices.isEmpty {
                    Button("Löschen") {
                        withAnimation {
                            viewItems.removeAll { item in
                                guard let index = viewItems.firstIndex(of: item) else { return false }
                                return selectedIndices.contains(index)
                            }
                            selectedIndices.removeAll()
                            save()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewItems.indices, id: \.self) { index in
                        let item = viewItems[index]
                        ZStack(alignment: .topTrailing) {
                            viewForType(item)
                                .overlay(
                                    editMode && selectedIndices.contains(index)
                                        ? RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red, lineWidth: 3)
                                        : nil
                                )
                                .onTapGesture {
                                    if editMode {
                                        if selectedIndices.contains(index) {
                                            selectedIndices.remove(index)
                                        } else {
                                            selectedIndices.insert(index)
                                        }
                                    }
                                }

                            if editMode {
                                Image(systemName: selectedIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedIndices.contains(index) ? .green : .gray)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
            }

            // 🔘 Hinzufügen-Button mit Glow & Gradient
            Button {
                showAddMenu = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .shadow(color: .white.opacity(0.5), radius: 4, y: 2)

                    Text("Element hinzufügen")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white, .white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue, .black],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue, radius: 10, y: 4)
                )
            }
            .padding(.bottom, 40)
            .confirmationDialog("Neues Element hinzufügen", isPresented: $showAddMenu) {
                ForEach(CustomViewType.allCases) { type in
                    Button(type.displayTitle) {
                        withAnimation {
                            viewItems.append(type)
                            save()
                        }
                    }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear(perform: load)
    }

    // MARK: - Ansicht für jeden Typ
    @ViewBuilder
    func viewForType(_ type: CustomViewType) -> some View {
        switch type {
        case .spiritGameView:
            SpiritGameView()
                .frame(height: 240)
                .environmentObject(SpiritGameController())

        case .eventGameView:
            EventGameView()
                .frame(height: 240)
                .environmentObject(SpiritGameController())

        case .homeView:
            HomeView()
                .frame(height: 500)
                .environmentObject(CoinManager.shared)
                .environmentObject(CrystalManager.shared)
                .environmentObject(AccountLevelManager.shared)
                .environmentObject(ArtefactInventoryManager.shared)
                .environmentObject(SpiritGameController())

        case .settingsView:
            SettingsView()
                .frame(height: 500)

        case .questView:
            QuestView()
                .frame(height: 500)

        case .giftView:
            GiftView()
                .environmentObject(GiftManager.shared)
                .frame(height: 500)

        case .eventButton:
            Button("Event Button") {
                print("Event Button tapped")
            }
            .font(.headline)
            .padding()
            .background(.blue)
            .clipShape(Capsule())

        case .stageText:
            Text("Stage 5")
                .font(.largeTitle.weight(.black))
                .foregroundColor(.cyan)
                .environmentObject(SpiritGameController())

        case .customText:
            Text("Willkommen")
                .font(.title3)
                .foregroundStyle(
                    LinearGradient(colors: [.cyan, .blue, .cyan],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )

        case .emptySpacer:
            Spacer().frame(height: 30)
            
        case .dailyLoginView:
            DailyLoginView()
                .frame(height: 500)

        case .hallOfFameView:
            HallOfFameView()
                .frame(height: 500)

        case .spiritListView:
            SpiritListView()
                .frame(height: 500)

        case .exchangeView:
            ExchangeView()
                .frame(height: 500)

        case .eventShopInventoryView:
            EventShopInventoryView()
                .frame(height: 500)

        case .multiplayerView:
            MultiplayerView()
                .frame(height: 500)

        }
    }

    // MARK: - Autosave
    private func save() {
        if let data = try? JSONEncoder().encode(viewItems) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([CustomViewType].self, from: data) {
            viewItems = decoded
        }
    }
}

#Preview {
    CustomViewBuilder()
}
