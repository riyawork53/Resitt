import SwiftUI

enum Theme {
    static let paper = Color.white
    static let ink = Color(red: 0.15, green: 0.16, blue: 0.19)
    static let accent = Color(red: 0.72, green: 0.20, blue: 0.26)
    static let blush = Color(red: 1.0, green: 0.92, blue: 0.93)
    static let surface = Color(red: 0.97, green: 0.97, blue: 0.98)
}

struct ResittBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.foregroundStyle(Theme.ink)
            .background(Theme.paper.ignoresSafeArea())
            .preferredColorScheme(.light)
    }
}

extension View {
    func resittStyle() -> some View { modifier(ResittBackground()) }
}
