import SwiftUI

struct WelcomeView: View {
    
    @State private var showText = false
    @State private var pulses: [PulseEffect] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Hintergrund
                LinearGradient(
                    colors: [.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Inhalt
                VStack(spacing: 50) {
                    
                    // Willkommen Text
                    Text("Welcome")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(showText ? 1 : 0)
                        .scaleEffect(showText ? 1 : 0.8)
                        .animation(.easeInOut(duration: 1.5), value: showText)
                        .onTapGesture {
                            pulseText()
                        }
                    
                    // --- START BUTTON ---
                    NavigationLink(destination: TutorialView()) {
                        Text("Start")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.blue.opacity(0.7))
                                    .shadow(color: .blue.opacity(0.7), radius: 12)
                            )
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        // kleiner Pulse Effekt beim Button
                        pulseText()
                    })
                }
                
                // Touch Effekte (rotierende Quadrate)
                ForEach(pulses) { pulse in
                    Rectangle()
                        .stroke(pulse.color, lineWidth: 3)
                        .frame(width: pulse.size, height: pulse.size)
                        .rotationEffect(.degrees(pulse.rotation))
                        .position(pulse.position)
                        .opacity(pulse.opacity)
                        .animation(.easeOut(duration: 0.8), value: pulse.opacity)
                }
            }
            .onAppear {
                withAnimation {
                    showText = true
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        spawnPulse(at: value.location, color: .blue)
                    }
                    .onEnded { value in
                        spawnPulse(at: value.location, color: .red)
                    }
            )
        }
    }
    
    // MARK: - Effekte
    
    func spawnPulse(at point: CGPoint, color: Color) {

        let newPulse = PulseEffect(
            position: point,
            opacity: 1,
            rotation: 0,
            color: color,
            size: CGFloat.random(in: 35...55)
        )

        let id = newPulse.id
        pulses.append(newPulse)

        // Animation
        DispatchQueue.main.async {
            if let index = pulses.firstIndex(where: { $0.id == id }) {
                pulses[index].rotation = 180
                pulses[index].opacity = 0
            }
        }

        // Remove
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            pulses.removeAll { $0.id == id }
        }
    }

    
    func pulseText() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showText = false
        }
        withAnimation(.easeInOut(duration: 0.3).delay(0.3)) {
            showText = true
        }
    }
}



#Preview {
    WelcomeView()
}
