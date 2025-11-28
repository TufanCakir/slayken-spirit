import SwiftUI

struct TutorialView: View {

    @State private var steps: [TutorialStep] = Bundle.main.decode(
        "tutorial.json"
    )
    @State private var currentIndex = 0

    @State private var showTitle = false
    @State private var showText = false
    @State private var showHint = false

    @State private var showWelcome = false

    var body: some View {
        ZStack {
            SpiritGridBackground()

            VStack {
                Spacer()

                Group {
                    if currentIndex < steps.count {
                        stepContent
                    } else {
                        finishedContent
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: currentIndex)

                Spacer()

                progressIndicator
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
        .onAppear { startStepAnimations() }
        .fullScreenCover(isPresented: $showWelcome) {
            FooterTabView()
                .transition(.opacity.combined(with: .scale))
        }
    }
}

//
// MARK: - Step Content
//

extension TutorialView {

    fileprivate var stepContent: some View {
        let step = steps[currentIndex]

        return VStack(spacing: 24) {

            if showTitle {
                Text(step.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if showText {
                Text(step.text)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .transition(.opacity.combined(with: .scale))
            }

            if showHint {
                Text("Tap to continue")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .opacity(showHint ? 1 : 0.3)
                    .animation(
                        .easeInOut(duration: 1).repeatForever(
                            autoreverses: true
                        ),
                        value: showHint
                    )
            }
        }
        .onTapGesture { nextStep() }
    }

    fileprivate var finishedContent: some View {
        VStack(spacing: 20) {
            Text("You're ready!")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white, .white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("Tap to begin your journey.")
                .font(.title.weight(.bold))
                .foregroundColor(.white)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                showWelcome = true
            }
        }
    }
}

//
// MARK: - Progress Indicator
//

extension TutorialView {
    fileprivate var progressIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<steps.count, id: \.self) { index in
                let isActive = index == currentIndex

                Circle()
                    .fill(
                        isActive
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [.black, .white, .black],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color.white.opacity(0.25))
                    )
                    .frame(
                        width: isActive ? 14 : 8,
                        height: isActive ? 14 : 8
                    )
                    .shadow(color: isActive ? .white : .clear, radius: 6)
                    .scaleEffect(isActive ? 1.3 : 1.0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8),
                        value: currentIndex
                    )
            }
        }
    }
}

//
// MARK: - Step Transition
//

extension TutorialView {

    fileprivate func startStepAnimations() {
        withAnimation(.easeOut(duration: 0.8)) { showTitle = true }
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) { showText = true }
        withAnimation(.easeIn(duration: 1.5).delay(1.0)) { showHint = true }
    }

    fileprivate func nextStep() {
        showTitle = false
        showText = false
        showHint = false

        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex += 1
        }

        guard currentIndex < steps.count else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            startStepAnimations()
        }
    }
}

#Preview {
    TutorialView()
        .preferredColorScheme(.dark)
}
