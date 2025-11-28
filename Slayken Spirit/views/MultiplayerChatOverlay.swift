import SwiftUI
internal import GameKit

struct MultiplayerChatOverlay: View {
    @State private var messages: [MultiplayerMessage] = [
        .init(senderName: "System", text: "Willkommen im Match!", timestamp: .now),
        .init(senderName: "System", text: "Bereit für den Kampf?", timestamp: .now)
    ]
    @State private var currentMessage: String = ""

    @Namespace private var scrollNamespace

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            // MARK: - Verlauf
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(messages.indices, id: \.self) { index in
                            let msg = messages[index]
                            VStack(alignment: .leading, spacing: 2) {
                                Text(msg.senderName)
                                    .font(.caption2)
                                    .foregroundColor(.cyan.opacity(0.8))
                                Text(msg.text)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .id(index)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 5)
                }
                .frame(maxHeight: 150)
                .onChange(of: messages.count) { _ in
                    // Scrollt automatisch zur letzten Nachricht
                    withAnimation {
                        proxy.scrollTo(messages.indices.last, anchor: .bottom)
                    }
                }
            }

            // MARK: - Eingabefeld
            HStack(spacing: 8) {
                TextField("Nachricht senden...", text: $currentMessage)
                    .font(.footnote)
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.cyan)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }

 

    
    // MARK: - Nachricht senden
    private func sendMessage() {
        let trimmed = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newMessage = MultiplayerMessage(
            senderName: GKLocalPlayer.local.displayName,
            text: trimmed,
            timestamp: .now
        )

        messages.append(newMessage)
        currentMessage = ""

        MatchManager.shared.sendActionData(MultiplayerAction.chatMessage(newMessage))
    }

}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MultiplayerChatOverlay()
    }
}
