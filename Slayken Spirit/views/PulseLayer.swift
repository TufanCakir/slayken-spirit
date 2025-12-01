import SwiftUI

struct PulseLayer: View {
    let pulses: [PulseEffect]

    var body: some View {
        ZStack {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
