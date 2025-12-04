import SwiftUI

struct WelcomeView: View {

    @State private var showText = false
    @StateObject private var pulse = PulseManager()

    var body: some View {
        NavigationStack {
            ZStack {

                MetalView()
                    .ignoresSafeArea()

                VStack(spacing: 50) {

                    Text("Willkommen zu Slayken Spirit")
                        .font(
                            .system(size: 48, weight: .bold, design: .rounded)
                        )
                        .foregroundColor(.white)
                        .opacity(showText ? 1 : 0)
                        .scaleEffect(showText ? 1 : 0.8)
                        .animation(.easeInOut(duration: 1.5), value: showText)
                        .onTapGesture { pulseText() }
                        .shadow(color: .black, radius: 12)

                    NavigationLink(destination: TutorialView()) {
                        Text("Start")
                            .font(
                                .system(
                                    size: 28,
                                    weight: .semibold,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(.black)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.white)
                                    .shadow(color: .black, radius: 12)
                            )
                    }
                }

                // GLOBAL pulse layer
                PulseLayer(pulses: pulse.pulses)
            }
            .onAppear { showText = true }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { pulse.spawnPulse(at: $0.location) }
            )
        }
    }

    func pulseText() {
        withAnimation(.easeInOut(duration: 0.3)) { showText = false }
        withAnimation(.easeInOut(duration: 0.3).delay(0.3)) { showText = true }
    }
}

#Preview {
    WelcomeView()
}
