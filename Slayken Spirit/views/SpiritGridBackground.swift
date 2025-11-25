import SwiftUI

struct SpiritGridBackground: View {
    var glowColor: Color = .blue      // ← dynamisch!

    var body: some View {
        ZStack {
            TimelineView(.animation) { (timeline: TimelineViewDefaultContext) in
                
                let gridSize: CGFloat = 50
                let lineWidth: CGFloat = 1.0
                let glow = glowColor      // ← hier benutzen!

                let t = timeline.date.timeIntervalSinceReferenceDate
                let offset = CGFloat(t.remainder(dividingBy: gridSize))
                let slowOffset = CGFloat((t * 0.35).remainder(dividingBy: gridSize))
                
                Canvas { context, size in
                    
                    // MARK: - Background Gradient
                    let bgGradient = Gradient(colors: [
                        .black,
                        .blue.opacity(0.25),
                        .black
                    ])
                    
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .linearGradient(
                            bgGradient,
                            startPoint: CGPoint(x: 0.5, y: 0),
                            endPoint: CGPoint(x: 0.5, y: 1)
                        )
                    )
                    
                    context.blendMode = .plusLighter
                    
                    var path = Path()
                    
                    // Vertical lines
                    for x in stride(from: 0, through: size.width, by: gridSize) {
                        let xx = x + offset
                        path.move(to: CGPoint(x: xx, y: 0))
                        path.addLine(to: CGPoint(x: xx, y: size.height))
                    }
                    
                    // Horizontal lines
                    for y in stride(from: 0, through: size.height, by: gridSize) {
                        let yy = y + slowOffset
                        path.move(to: CGPoint(x: 0, y: yy))
                        path.addLine(to: CGPoint(x: size.width, y: yy))
                    }
                    
                    // Base lines
                    context.stroke(path,
                                   with: .color(glow.opacity(0.28)),
                                   lineWidth: lineWidth)
                    
                    // Glow
                    context.addFilter(.shadow(color: glow.opacity(0.9), radius: 8))
                    context.drawLayer { layer in
                        layer.stroke(path,
                                     with: .color(glow.opacity(0.85)),
                                     lineWidth: lineWidth)
                    }
                }
            }
        }
        .ignoresSafeArea()      // <- garantiert wirklich fullscreen
        .background(Color.black) // <- verhindert weißes Flashing beim Transition
    }
}

#Preview {
    SpiritGridBackground()
}
