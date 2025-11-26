import SwiftUI
import GameKit

struct GameCenterLoginButton: View {
    @ObservedObject private var gc = GameCenterManager.shared

    var body: some View {
        Button {
            GameCenterManager.shared.authenticate()
        } label: {
            HStack(spacing: 12) {

                Image(systemName: gc.isAuthenticated
                      ? "checkmark.seal.fill"
                      : "person.crop.circle.badge.plus")
                    .font(.title3)
                    .foregroundColor(gc.isAuthenticated ? .green : .yellow)

                Text(
                    gc.isAuthenticated
                    ? "Logged in as: \(gc.playerName)"
                    : "Sign in to Game Center"
                )
                .foregroundColor(.white)
                .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.thinMaterial)
            .cornerRadius(16)
        }
    }
}
