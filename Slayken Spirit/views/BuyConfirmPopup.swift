import SwiftUI

struct BuyConfirmPopup: View {

    let item: EventShopItem
    let onBuy: () -> Void
    let onCancel: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {

            // DARKENED BACKDROP
            Color.black.opacity(animate ? 0.55 : 0)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            // POPUP
            VStack(spacing: 18) {

                // TITLE
                Text("Confirm Purchase")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 6)

                // MESSAGE
                Text("Buy \(item.name) for \(item.price) Spirit Points?")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // BUTTONS
                HStack(spacing: 16) {

                    // CANCEL BUTTON
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // BUY BUTTON
                    Button(action: onBuy) {
                        Text("Buy")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .red.opacity(0.6), radius: 10, y: 4)
                    }
                }
                .padding(.horizontal, 20)

            }
            .padding(.vertical, 24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 25, y: 6)
            .padding(.horizontal, 40)
            .scaleEffect(animate ? 1 : 0.7)
            .opacity(animate ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    animate = true
                }
            }
            .onDisappear {
                animate = false
            }
        }
    }
}
