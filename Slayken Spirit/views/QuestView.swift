import SwiftUI

struct QuestView: View {

    @State private var quests: [Quest] = Bundle.main.decode("quests.json")
    @ObservedObject private var questManager = QuestManager.shared
    @State private var selectedQuest: Quest?



    var body: some View {
        ZStack {
            SpiritGridBackground(glowColor: .yellow)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

         
                    ForEach(quests) { quest in
                        questCard(quest)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(item: $selectedQuest) { quest in
            QuestRewardDetailView(quest: quest)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}



private extension QuestView {
    
    func questCard(_ quest: Quest) -> some View {

        let progress = questManager.progress(for: quest)
        let ratio = min(1.0, Double(progress) / Double(quest.target))

        let isDone = progress >= quest.target
        let isClaimed = questManager.completed.contains(quest.id)

        return VStack(alignment: .leading, spacing: 16) {

            // HEADER
            HStack {
                Text(QuestManager.shared.localizedTitle(for: quest))
                    .font(.headline.bold())
                    .foregroundColor(.white)

                Spacer()

                Button {
                    selectedQuest = quest
                } label: {
                    Image(systemName: "info.circle")
                        .font(.headline.bold())
                        .foregroundColor(.white)


                }
            }

            // DESCRIPTION
            Text(QuestManager.shared.localizedDescription(for: quest))
                .font(.headline.bold())
                .foregroundColor(.white)

            // PROGRESS BAR
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.12))

                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(colors: [.cyan, .blue.opacity(0.7)],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(width: UIScreen.main.bounds.width * 0.75 * ratio)
                        .animation(.easeInOut(duration: 0.25), value: ratio)
                }
                .frame(height: 14)

                Text("\(progress) / \(quest.target)")
                    .font(.headline.bold())
                    .foregroundColor(.white.opacity(0.7))
            }

            // CLAIM BUTTON
            Button {
                questManager.claim(quest)
            } label: {
                Text(
                    isClaimed ? "Erhalten"
                    : (isDone ? "Belohnung abholen" : "Noch nicht erfüllt")
                )
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            isClaimed ?
                                LinearGradient(colors: [Color.green.opacity(0.25), Color.green.opacity(0.25)], startPoint: .top, endPoint: .bottom) :
                                (isDone ?
                                    LinearGradient(colors: [.green, .green.opacity(0.75)], startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                                )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .disabled(!isDone || isClaimed)

        }
        .padding(18)
        .background(Color.white.opacity(0.05).blur(radius: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.5), radius: 10, y: 6)
    }
}

@ViewBuilder
func rewardLabel(_ text: String, value: Int?, icon: String) -> some View {
    HStack(spacing: 6) {
        Image(systemName: icon).foregroundColor(.white)
        Text(value != nil ? "\(text): \(value!)" : text)
            .foregroundColor(.white)
            .font(.caption)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 5)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 10))
}

#Preview {
    QuestView()
}
