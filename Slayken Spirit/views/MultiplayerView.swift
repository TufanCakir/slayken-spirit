import SwiftUI
internal import GameKit

struct MultiplayerView: View {
    
    @ObservedObject var gameCenterManager = GameCenterManager.shared
    @ObservedObject var matchManager = MatchManager.shared
    
    @State private var isShowingMatchmaker = false
    @State private var matchmakerParams: (min: Int, max: Int)? = nil

    var body: some View {
        ZStack {
            SpiritGridBackground(glowColor: .blue)
                .ignoresSafeArea()
            
            NavigationStack {
                ZStack {
                    SpiritGridBackground(glowColor: .blue)
                        .ignoresSafeArea()
                    
                    // TITLE
                                  Text("Wähle deinen Spielmodus")
                                      .font(.system(size: 28, weight: .bold, design: .rounded))
                                      .foregroundStyle(.white)
                                      .padding(.top, 40)

                                  // --- MODUS-KARUSSELL ---
                                  TabView {
                                      modeCard(
                                          title: "1v1 Echtzeit",
                                          icon: "bolt.fill",
                                          iconColor: .yellow,
                                          gradient: [.cyan, .blue, .black],
                                          players: (2, 2)
                                      )

                                      modeCard(
                                          title: "2-4 Spieler Match",
                                          icon: "person.3.fill",
                                          iconColor: .green,
                                          gradient: [.blue, .black],
                                          players: (2, 4)
                                      )

                                      modeCard(
                                          title: "Koop Raid",
                                          icon: "flame.fill",
                                          iconColor: .blue,
                                          gradient: [.red, .red, .black],
                                          players: nil,
                                          disabled: true
                                      )

                                      modeCard(
                                          title: "Training",
                                          icon: "figure.run.circle.fill",
                                          iconColor: .black,
                                          gradient: [.gray, .gray, .black],
                                          players: nil,
                                          disabled: true
                                      )
                                  }
                    .tabViewStyle(.page)
                    .frame(height: 200)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 300)

                    Spacer()

                    // --- MATCH STATUS ---
                    if matchManager.isMatchActive {
                        VStack(spacing: 12) {
                           
                            Text("🟢 \(matchManager.matchStateText)")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text("Teilnehmer:")
                                    .foregroundColor(.white)
                                    .bold()
                                
                                ForEach(matchManager.connectedPlayers, id: \.gamePlayerID) { player in
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.cyan)
                                        Text(player.displayName)
                                            .foregroundColor(.white)
                                    }
                                }
                            }

                            Button("❌ Match verlassen") {
                                matchManager.leaveMatch()
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.3))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }

                }
            }
            .navigationDestination(isPresented: Binding(
                get: { matchManager.isMatchActive },
                set: { _ in }
            )) {
                SpiritGameView().environmentObject(SpiritGameController())
            }
        }
      
        
        .sheet(isPresented: $isShowingMatchmaker) {
            if let params = matchmakerParams {
                MatchmakerModalView(minPlayers: params.min, maxPlayers: params.max)
            }
        }
    }

    // MARK: - Einzelne Modus-Karte
       @ViewBuilder
       private func modeCard(
           title: String,
           icon: String,
           iconColor: Color,
           gradient: [Color],
           players: (Int, Int)?,
           disabled: Bool = false
       ) -> some View {
           Button {
               if let p = players, !disabled {
                   matchmakerParams = p
                   isShowingMatchmaker = true
               }
           } label: {
               ZStack {
                   RoundedRectangle(cornerRadius: 30)
                       .fill(
                           LinearGradient(
                               colors: gradient,
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                           )
                       )
                       .shadow(radius: 10)

                   VStack(spacing: 12) {
                       Image(systemName: icon)
                           .font(.system(size: 40))
                           .foregroundColor(iconColor)

                       Text(title)
                           .font(.system(size: 22, weight: .bold, design: .rounded))
                           .foregroundColor(.white)
                   }
                   .padding()
               }
           }
           .padding(.horizontal, 10)
           .frame(height: 180)
           .disabled(disabled || !gameCenterManager.isAuthenticated)
       }
   }


#Preview {
    MultiplayerView()
}
