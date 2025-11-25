import SwiftUI

struct OfflineScreen: View {
    var body: some View {
        ZStack {
            SpiritGridBackground()

        }
        VStack(spacing: 20) {
            
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.red)
                .padding(.bottom, 20)
            
            Text("No Internet Connection")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("Slayken Spirit requires an active internet connection for Game Center, daily rewards and syncing your progress.")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding(.top, 20)
        }
        .padding()

    }
}
