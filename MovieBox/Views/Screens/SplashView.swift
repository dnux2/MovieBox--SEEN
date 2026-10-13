import SwiftUI

struct SplashView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            AppBackground()          // شلنا التعليق
                .ignoresSafeArea()   // عشان تغطي الشاشة كلها

            VStack(spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .scaleEffect(appeared ? 1 : 0.7)
            }
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                appeared = true
            }
        }
    }
}

#Preview {
    SplashView()
}
