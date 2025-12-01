import SwiftUI

struct PulseEffect: Identifiable {
    let id = UUID()
    var position: CGPoint
    var opacity: Double
    var rotation: Double
    var color: Color
    var size: CGFloat
}
