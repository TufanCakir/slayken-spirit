import SwiftUI

struct OfflineScreen: View {
    var body: some View {
        ZStack {
            // MARK: - Hintergrund (animiertes Grid o.Ä.)
            SpiritGridBackground()
                .ignoresSafeArea()

            // MARK: - Inhalt
            VStack(spacing: 24) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.red, .white)
                    .shadow(color: .red.opacity(0.4), radius: 10, y: 4)
                    .padding(.bottom, 10)

                Text("No Internet Connection")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4)

                Text(
                    "Slayken Spirit requires an active internet connection to enable Game Center, daily rewards, and syncing your progress."
                )
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
                    .padding(.top, 12)
            }
            .padding()
        }
    }
}

#Preview {
    OfflineScreen()
        .preferredColorScheme(.dark)
}
