import SwiftUI

struct HomeButtonView: View {
    let button: HomeButton
    var action: (() -> Void)? = nil

    @State private var isPressed = false
    @State private var glowPulse = false

    var body: some View {
        VStack(spacing: 10) {

            // MARK: - Icon mit Glow-Effekt
            ZStack {
                Circle()
                    .fill(Color(hex: button.color))
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: Color(hex: button.iconColor).opacity(0.6),
                        radius: 14
                    )
                    .shadow(color: .white.opacity(0.15), radius: 4)
                    .scaleEffect(glowPulse ? 1.05 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.4)
                            .repeatForever(autoreverses: true),
                        value: glowPulse
                    )

                Image(systemName: button.icon)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(Color(hex: button.iconColor))
                    .shadow(
                        color: Color(hex: button.iconColor).opacity(0.4),
                        radius: 6
                    )
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: isPressed
            )

            // MARK: - Titel
            Text(button.title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.6), radius: 2)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .padding()
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(
            .spring(response: 0.3, dampingFraction: 0.7),
            value: isPressed
        )
        .onAppear {
            glowPulse = true
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = false
                    }
                    action?()
                }
        )
    }
}
