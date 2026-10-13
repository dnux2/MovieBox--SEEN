import SwiftUI

struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    private var colors: [Color] {
        if colorScheme == .dark {
            return [/*Color.accentColor,*/.black]
        } else {
            return [
                Color.accentColor.opacity(0.35),
                Color(.systemBackground)
            ]
        }
    }

    var body: some View {
        LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top)
            .ignoresSafeArea()
    }
}
