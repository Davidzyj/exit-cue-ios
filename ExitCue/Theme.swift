import SwiftUI

enum ECTheme {
    static let background = Color(red: 0.95, green: 0.93, blue: 0.88)
    static let surface = Color(red: 1.0, green: 0.99, blue: 0.96)
    static let elevated = Color.white
    static let ink = Color(red: 0.11, green: 0.12, blue: 0.14)
    static let muted = Color(red: 0.34, green: 0.36, blue: 0.40)
    static let placeholder = Color(red: 0.43, green: 0.45, blue: 0.49)
    static let disabledText = Color(red: 0.42, green: 0.43, blue: 0.45)
    static let line = Color(red: 0.80, green: 0.77, blue: 0.70)
    static let teal = Color(red: 0.13, green: 0.42, blue: 0.49)
    static let coral = Color(red: 0.82, green: 0.31, blue: 0.31)
    static let brass = Color(red: 0.49, green: 0.41, blue: 0.18)
    static let green = Color(red: 0.21, green: 0.49, blue: 0.35)
    static let softGreen = Color(red: 0.86, green: 0.93, blue: 0.86)
    static let softCoral = Color(red: 0.98, green: 0.88, blue: 0.84)
    static let softBlue = Color(red: 0.85, green: 0.93, blue: 0.95)
    static let shadow = Color.black.opacity(0.10)
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red: Double
        let green: Double
        let blue: Double

        if cleaned.count == 6 {
            red = Double((value & 0xFF0000) >> 16) / 255.0
            green = Double((value & 0x00FF00) >> 8) / 255.0
            blue = Double(value & 0x0000FF) / 255.0
        } else {
            red = 0.13
            green = 0.42
            blue = 0.49
        }
        self.init(red: red, green: green, blue: blue)
    }
}

struct ECPrimaryButtonStyle: ButtonStyle {
    var isDisabled = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(isDisabled ? ECTheme.disabledText : Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isDisabled ? ECTheme.line.opacity(0.55) : ECTheme.teal)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.98 : 1)
    }
}

struct ECSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(ECTheme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(ECTheme.elevated)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(ECTheme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct ECDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(ECTheme.coral)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

