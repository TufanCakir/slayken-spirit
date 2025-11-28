import SwiftUI

struct SpiritGridBackground: View {
    var glowColor: Color = .blue
    var intensity: Double = 1.0  // <--- NEU

    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in

                let gridSize: CGFloat = 50
                let lineWidth: CGFloat = 1.2

                let t = timeline.date.timeIntervalSinceReferenceDate
                let offset = CGFloat(t.remainder(dividingBy: gridSize))
                let slowOffset = CGFloat(
                    (t * 0.35).remainder(dividingBy: gridSize)
                )

                Canvas { context, size in

                    // background
                    let bgGradient = Gradient(colors: [
                        .black,
                        glowColor.opacity(0.15 * intensity),  // mehr Farbe!
                        .black,
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

                    // vertical
                    for x in stride(from: 0, through: size.width, by: 50) {
                        let xx = x + offset
                        path.move(to: CGPoint(x: xx, y: 0))
                        path.addLine(to: CGPoint(x: xx, y: size.height))
                    }

                    // horizontal
                    for y in stride(from: 0, through: size.height, by: 50) {
                        let yy = y + slowOffset
                        path.move(to: CGPoint(x: 0, y: yy))
                        path.addLine(to: CGPoint(x: size.width, y: yy))
                    }

                    let strong = intensity

                    // Base Stroke
                    context.stroke(
                        path,
                        with: .color(glowColor.opacity(0.35 * strong)),
                        lineWidth: lineWidth
                    )

                    // Glow
                    context.addFilter(
                        .shadow(
                            color: glowColor.opacity(0.9 * strong),
                            radius: 12 * strong
                        )
                    )  // <--- starker Glow!

                    context.drawLayer { layer in
                        layer.stroke(
                            path,
                            with: .color(glowColor.opacity(0.85 * strong)),
                            lineWidth: lineWidth
                        )
                    }
                }
            }
        }
        .ignoresSafeArea()
        .background(Color.black)
    }
}

#Preview {
    SpiritGridBackground()
}
