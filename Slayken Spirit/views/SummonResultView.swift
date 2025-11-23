import SwiftUI

struct SummonResultView: View {

    let results: [String]   // IDs wie "spirit_fire", "spirit_ice"

    var body: some View {
        VStack(spacing: 20) {

            Text("Summon Results")
                .font(.largeTitle.bold())
                .padding(.top, 20)

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(results, id: \.self) { id in
                        resultCard(id)
                    }
                }
                .padding()
            }

            Button("Done") { dismiss() }
                .font(.title3.bold())
                .padding()
        }
    }

    @Environment(\.dismiss) private var dismiss
}

private extension SummonResultView {

    func resultCard(_ id: String) -> some View {

        HStack(spacing: 15) {
            Image(id) // falls du PNGs oder Icons hast
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(id)
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
