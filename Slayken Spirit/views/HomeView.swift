import SwiftUI

struct HomeView: View {

    @State private var buttons: [HomeButton] = Bundle.main.decode("homeButtons.json")

 
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        NavigationStack {
            ZStack {

                SpiritGridBackground()

                VStack(spacing: 0) {

                    HeaderView()
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(buttons) { button in
                                NavigationLink(
                                    destination: ScreenFactory.shared.make(button.destination)
                                ) {
                                    HomeButtonView(button: button)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 60)
                    }
                }
                .zIndex(1)
            }
            .navigationBarHidden(true)
        }
    }
}

struct HomeBackgroundView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.4), value: imageName)
    }
}



#Preview {
    HomeView()
        .environmentObject(CoinManager.shared)
        .environmentObject(CrystalManager.shared)
        .environmentObject(AccountLevelManager.shared)
        .preferredColorScheme(.dark)
        .environmentObject(SpiritGameController())
}
