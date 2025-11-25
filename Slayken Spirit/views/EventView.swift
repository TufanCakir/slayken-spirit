import SwiftUI

struct EventView: View {
    
    @EnvironmentObject private var game: SpiritGameController

    @State private var events: [GameEvent] = []
    @State private var selectedEvent: GameEvent?
    @State private var showBattle: Bool = false
    @State private var activeSheet: ActiveSheet?
    @State private var gameButtons: [GameButton] = Bundle.main.loadGameButtons()
    enum ActiveSheet: Identifiable {
        case upgrade
        case artefacts

        var id: Int { hashValue }
    }
    
  
    init() {
        // Move potentially throwing decoding out of the property initializer
        let decoded: [GameEvent]
        do {
            decoded = try Bundle.main.decodeSafe("events.json")
        } catch {
            // Fallback to empty list on failure; consider logging in real app
            decoded = []
        }
        _events = State(initialValue: decoded)
    }
    
    var body: some View {
        ZStack {
          
            SpiritGridBackground()

     
            VStack(spacing: 22) {

                Text("Events")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .cyan],
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
                    .shadow(radius: 10)
                    .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(events) { event in
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
            SpiritGridBackground(glowColor: Color(hex: event.gridColor))
                .clipShape(RoundedRectangle(cornerRadius: 20))   // <- wichtig!!!
                .frame(height: 200)                               // <- Card Größe
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.red, lineWidth: 3)
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

struct EventDetailView: View {
    let event: GameEvent
    @Binding var showBattle: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: SpiritGameController

    var body: some View {
        VStack(spacing: 20) {

            Text(event.name)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(.white)

            // 🔥 CARD-Grid — NICHT fullscreen!
            SpiritGridBackground(glowColor: Color(hex: event.gridColor))
                .clipShape(RoundedRectangle(cornerRadius: 20))   // <- wichtig!!!
                .frame(height: 200)                               // <- Card Größe
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.red, lineWidth: 3)
                )
            
            
            Text(event.description)
                .foregroundColor(.white.opacity(0.8))
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
            LinearGradient(colors: [.black, .blue.opacity(0.4)],
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
