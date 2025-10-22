import SwiftUI

extension View {
    /// Scales text based on screen width and user Dynamic Type settings.
    /// Uses iPhone 8 (375 pt width) as the baseline.
    func responsiveFont(
        _ textStyle: Font.TextStyle,
        baseWidth: CGFloat = 375,   // iPhone 8 width
        baseHeight: CGFloat = 667   // iPhone 8 height
    ) -> some View {
        modifier(ResponsiveFontModifier(textStyle: textStyle, baseWidth: baseWidth, baseHeight: baseHeight))
    }
}

private struct ResponsiveFontModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let textStyle: Font.TextStyle
    let baseWidth: CGFloat
    let baseHeight: CGFloat
    

    func body(content: Content) -> some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenDiagonal: CGFloat = {
            return sqrt(screenWidth * screenWidth + screenHeight * screenHeight)
        }()
        let baseDiagonal: CGFloat = {
            return sqrt(baseWidth * baseWidth + baseHeight * baseHeight)
        }()
        let screenScale = screenDiagonal / baseDiagonal
        
        // Base point sizes for each style (rough Apple defaults)
        let baseSize: CGFloat = {
            switch textStyle {
            case Font.TextStyle.largeTitle: return 34
            case Font.TextStyle.title: return 28
            case Font.TextStyle.title2: return 22
            case Font.TextStyle.title3: return 20
            case Font.TextStyle.headline: return 17
            case Font.TextStyle.body: return 17
            case Font.TextStyle.callout: return 16
            case Font.TextStyle.subheadline: return 15
            case Font.TextStyle.footnote: return 13
            case Font.TextStyle.caption: return 12
            case Font.TextStyle.caption2: return 11
            @unknown default: return 17
            }
        }()

        // Combine screen and Dynamic Type scaling
        var fontSize = baseSize * screenScale * dynamicTypeSize.scaleFactor

        // Clamp to avoid absurdly large text on iPad + accessibility
        fontSize = min(fontSize, baseSize * 3.0)

        return content.font(.system(size: fontSize))
    }
}

private extension DynamicTypeSize {
    var scaleFactor: CGFloat {
        switch self {
        case .xSmall: return 0.8
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        case .xLarge: return 1.2
        case .xxLarge: return 1.35
        case .xxxLarge: return 1.5
        default: return 1.0
        }
    }
}
