import SwiftUI

struct TestScoreButton: View {

    @ObservedObject private var gc = GameCenterManager.shared
    @State private var isSending = false
    @State private var successMessage = ""

    var body: some View {
        VStack(spacing: 6) {

            Button {
                sendTestScore()
            } label: {
                HStack(spacing: 12) {

                    if isSending {
                        ProgressView()
                            .tint(.cyan)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.cyan)
                    }

                    Text("Send Test Score (1000)")
                        .foregroundColor(.white)
                        .font(.headline)

                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .cyan.opacity(0.25), radius: 10, y: 4)
            }

            if !successMessage.isEmpty {
                Text(successMessage)
                    .font(.footnote)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
        }
    }


    // MARK: - Logik
    private func sendTestScore() {
        guard gc.isAuthenticated else {
            successMessage = "❌ Nicht eingeloggt!"
            return
        }

        isSending = true
        successMessage = ""

        Task {
            await GCHighestStage.submit(1000)   // Score 1000 senden

            withAnimation {
                isSending = false
                successMessage = "✔️ Test Score erfolgreich gesendet!"
            }

            // Nachricht nach 2 Sekunden ausblenden
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    successMessage = ""
                }
            }
        }
    }
}
