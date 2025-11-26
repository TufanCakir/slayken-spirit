import SwiftUI
import GameKit

struct GameCenterLoginButton: View {
    @ObservedObject private var gc = GameCenterManager.shared

    @State private var showLoginAlert = false
    @State private var showLogoutAlert = false
    @State private var isLoading = false

    var body: some View {
        Button {
            if gc.isAuthenticated {
                showLogoutAlert = true     // 👉 Logout Popup
            } else {
                showLoginAlert = true      // 👉 Login Popup
            }
        } label: {
            HStack(spacing: 14) {

                // MARK: - Icon (Loading / Login / Logout)
                Group {
                    if isLoading {
                        ProgressView()
                            .tint(.cyan)
                    } else {
                        Image(systemName: gc.isAuthenticated
                              ? "checkmark.seal.fill"
                              : "person.crop.circle.badge.plus")
                            .foregroundColor(gc.isAuthenticated ? .green : .yellow)
                    }
                }
                .font(.title3)

                // MARK: - TEXT
                VStack(alignment: .leading, spacing: 2) {
                    Text(gc.isAuthenticated ? "Logged in as:" : "Sign in to Game Center")
                        .foregroundColor(.white.opacity(0.95))
                        .font(.headline)

                    Text(gc.isAuthenticated ? gc.playerName : "Tap to connect")
                        .foregroundColor(.cyan.opacity(0.85))
                        .font(.subheadline)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1.2)
            )
            .shadow(color: .cyan.opacity(0.25), radius: 12, y: 4)
        }

        // MARK: - LOGIN POPUP
        .alert("Game Center Login", isPresented: $showLoginAlert) {
            Button("Cancel", role: .cancel) {}

            Button("Login", role: .none) {
                Task {
                    isLoading = true
                    GameCenterManager.shared.authenticate { success, _ in
                        withAnimation { isLoading = false }
                    }
                }
            }
        } message: {
            Text("Sign in to unlock global leaderboards, rank rewards, and online features.")
        }

        // MARK: - LOGOUT POPUP
        .alert("Logout Game Center", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}

            Button("Logout", role: .destructive) {
                withAnimation {
                    gc.isAuthenticated = false
                    gc.playerName = "Not logged in"
                }
            }
        } message: {
            Text("Do you really want to disconnect from Game Center?")
        }
    }
}
