import SwiftUI

enum Theme {
    static let paper = Color(red: 0.96, green: 0.95, blue: 0.90)
    static let ink = Color(red: 0.16, green: 0.25, blue: 0.22)
    static let moss = Color(red: 0.77, green: 0.84, blue: 0.65)
    static let peach = Color(red: 0.96, green: 0.77, blue: 0.63)
}

struct GardenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.foregroundStyle(Theme.ink)
            .background(Theme.paper.ignoresSafeArea())
            .preferredColorScheme(.light)
    }
}

extension View {
    func gardenStyle() -> some View { modifier(GardenBackground()) }
}
