import SwiftUI

struct MultiplayerChatOverlay: View {
    @State private var messages: [String] = [
        "Willkommen im Match!",
        "Bereit für den Kampf?",
    ]
    @State private var currentMessage: String = ""
    
    var body: some View {
        VStack {
            Spacer()

            // --- Chatverlauf ---
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(messages.indices, id: \.self) { index in
                        Text(messages[index])
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                    }
                }
            }
            .frame(maxHeight: 150)
            .padding(.horizontal, 10)

            // --- Eingabefeld ---
            HStack {
                TextField("Nachricht senden...", text: $currentMessage)
                    .font(.footnote)
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.cyan)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding([.horizontal, .bottom], 10)
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .padding()
    }

    func sendMessage() {
        guard !currentMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messages.append(currentMessage)
        currentMessage = ""
        // TODO: Hier kannst du später `MatchManager.shared.sendActionData(...)` aufrufen
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MultiplayerChatOverlay()
    }
}
