import SwiftUI

let primaryGradient = LinearGradient(
    colors: [
        Color(red: 1, green: 0.85, blue: 0.0),
        Color(red: 0.0, green: 0.78, blue: 0.58),
        Color(red: 0.0, green: 0.68, blue: 0.95)
    ],
    startPoint: .leading,
    endPoint: .trailing
)

extension Color {
    static let primaryGreen = Color(red: 0.0, green: 0.78, blue: 0.58)
    static let primaryYellow = Color(red: 1, green: 0.85, blue: 0.0)
    static let primaryBlue = Color(red: 0.0, green: 0.68, blue: 0.95)
}
