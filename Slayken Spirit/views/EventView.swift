import SwiftUI


struct EventView: View {
    
    @EnvironmentObject private var game: SpiritGameController

    @State private var events: [GameEvent] = []
    @State private var selectedEvent: GameEvent?
    @State private var showBattle: Bool = false

    @State private var selectedCategory: EventCategory? = nil // nil = ALL
    
    init() {
        let decoded: [GameEvent]
        do {
            decoded = try Bundle.main.decodeSafe("events.json")
        } catch {
            decoded = []
        }
        _events = State(initialValue: decoded)
    }
    
    // 🔥 Kategorien für Leiste
    private var categories: [EventCategory] {
        EventCategory.allCases
    }
    
    // 🔥 Gefilterte Events
    private var filteredEvents: [GameEvent] {
        if let cat = selectedCategory {
            return events.filter { $0.category == cat }
        }
        return events
    }

    var body: some View {
        ZStack {
            SpiritGridBackground()

            VStack(spacing: 22) {

                // 🔥 CATEGORY BAR
                categoryBar

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredEvents) { event in
                            eventCard(event)
                                .onTapGesture {
                                    selectedEvent = event
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event, showBattle: $showBattle)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showBattle) {
            EventGameView()
                .environmentObject(game)
        }
    }
}

private extension EventView {
    
    func eventCard(_ event: GameEvent) -> some View {
        ZStack {
            // 🔥 CARD-Grid — NICHT fullscreen!
            SpiritGridBackground(
                glowColor: Color(hex: event.gridColor),
                intensity: 2.0           // doppelte Stärke
            )
            .shadow(color: Color(hex: event.gridColor).opacity(0.9), radius: 20)

                 .clipShape(RoundedRectangle(cornerRadius: 20))
                 .frame(height: 200)
                 .overlay(
                     RoundedRectangle(cornerRadius: 20)
                         .stroke(Color(hex: event.gridColor), lineWidth: 3) // optional schöner
                 )  // <- wichtig!!!
                .frame(height: 200)                               // <- Card Größe
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.blue, lineWidth: 3)
                )
            
            HStack {
                VStack(alignment: .center, spacing: 6) {
                    
                    Text(event.name)
                        .font(.system(size: 45, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    
                    /* Optional:
                     Text(event.description)
                     .font(.system(size: 16, weight: .medium))
                     .foregroundColor(.white.opacity(0.8))
                     .lineLimit(1)
                     */
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 5)
    }
}

private extension EventView {

    var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {

                // ALL Button
                categoryButton(
                    title: "All",
                    isActive: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                // Dynamisch Kategorien erzeugen
                ForEach(categories, id: \.self) { cat in
                    categoryButton(
                        title: cat.rawValue.capitalized,
                        isActive: selectedCategory == cat
                    ) {
                        selectedCategory = cat
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }

    // UI für einzelne Kategorie-Buttons
    func categoryButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(
                        isActive
                        ? Color.blue.opacity(0.8)
                        : Color.white.opacity(0.15)
                    )
                )
                .overlay(
                    Capsule().stroke(isActive ? Color.white : Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: isActive ? .blue.opacity(0.6) : .clear, radius: 8)
        }
    }
}


struct EventDetailView: View {
    let event: GameEvent
    @Binding var showBattle: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: SpiritGameController

    var body: some View {
        VStack(spacing: 20) {

   

            // 🔥 CARD-Grid — NICHT fullscreen!
            SpiritGridBackground(
                glowColor: Color(hex: event.gridColor),
                intensity: 2.0           // doppelte Stärke
            )
            .shadow(color: Color(hex: event.gridColor).opacity(0.9), radius: 20)

                .clipShape(RoundedRectangle(cornerRadius: 20))   // <- wichtig!!!
                .frame(height: 200)                               // <- Card Größe
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.blue, lineWidth: 3)
                )
            
            
            
            Text(event.description)
                .font(Font.body.italic())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: {
                game.startEvent(event)
                dismiss()
                showBattle = true
            }) {
                Text("Start Battle")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(.blue)
                    .clipShape(Capsule())
            }

            .padding(.bottom, 20)
        }
        .padding()
        .background(
            LinearGradient(colors: [.black, .blue, .blue],
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    EventView()
        .environmentObject(SpiritGameController())
}
