import SwiftUI
internal import Combine

class PulseManager: ObservableObject {
    @Published var pulses: [PulseEffect] = []

    func spawnPulse(at point: CGPoint) {
        let hue = Double.random(in: 0...1)

        let pulse = PulseEffect(
            position: point,
            opacity: 1,
            rotation: 0,
            color: Color(hue: hue, saturation: 1, brightness: 1),
            size: CGFloat.random(in: 35...55),
            hue: hue
        )

        let id = pulse.id
        pulses.append(pulse)

        DispatchQueue.main.async {
            if let idx = self.pulses.firstIndex(where: { $0.id == id }) {
                self.pulses[idx].rotation = 180
                self.pulses[idx].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.pulses.removeAll { $0.id == id }
        }
    }
}
