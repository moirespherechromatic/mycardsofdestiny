import SwiftUI

struct AppTheme {
    
    // MARK: - Colors
    struct Colors {
        static let primaryBackground = Color(red: 0.86, green: 0.75, blue: 0.55)
        static let secondaryBackground = Color(red: 0.95, green: 0.91, blue: 0.82)
        static let cardBackground = Color(red: 0.95, green: 0.91, blue: 0.82)
        static let primaryText = Color.black
        static let secondaryText = Color.black.opacity(0.7)
        static let accentColor = Color.black.opacity(0.8)
        static let darkAccent = Color.black
        static let goldAccent = Color(red: 0.83, green: 0.69, blue: 0.22)
        static let shadowColor = Color.black.opacity(0.3)
        static let deepShadowColor = Color.black.opacity(0.4)
    }
    
    // MARK: - Fonts
    struct Fonts {
        static let largeTitle = Font.custom("Apothicaire Light Cd", size: 34).weight(.heavy)
        static let title = Font.custom("Apothicaire Light Cd", size: 22).weight(.heavy)
        static let subtitle = Font.custom("Apothicaire Light Cd", size: 18).weight(.medium)
        static let headline = Font.custom("Apothicaire Light Cd", size: 18).weight(.heavy)
        static let body = Font.custom("Apothicaire Light Cd", size: 16).weight(.heavy)
        static let caption = Font.custom("Apothicaire Light Cd", size: 12).weight(.heavy)
        static let mysticalTitle = Font.custom("Apothicaire Light Cd", size: 28).weight(.heavy)
        static let cardTitle = Font.custom("Apothicaire Light Cd", size: 16).weight(.heavy)
        static let sectionHeader = Font.custom("Apothicaire Light Cd", size: 20).weight(.heavy)
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let cardOpacity: Double = 0.3
        static let cardRadius: CGFloat = 4
        static let cardOffset = CGSize(width: 0, height: 2)
        
        static let detailOpacity: Double = 0.4
        static let detailRadius: CGFloat = 6
        static let detailOffset = CGSize(width: 0, height: 3)
        
        static let lightOpacity: Double = 0.2
        static let lightRadius: CGFloat = 2
        static let lightOffset = CGSize(width: 0, height: 1)
    }
    
    // MARK: - Spacing (using AppConstants values for consistency)
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 40
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    static let backgroundColor = Colors.primaryBackground
    static let cardBackground = Colors.cardBackground
    static let darkAccent = Colors.darkAccent
    static let shadowColor = Colors.shadowColor
    static let primaryText = Colors.primaryText
    static let secondaryText = Colors.secondaryText
    static let accentColor = Colors.accentColor
    static let goldAccent = Colors.goldAccent
    
    static let largeTitle = Fonts.largeTitle
    static let title = Fonts.title
    static let headline = Fonts.headline
    static let body = Fonts.body
    static let caption = Fonts.caption
    static let mysticalTitle = Fonts.mysticalTitle
    
    static let paddingSmall: CGFloat = Spacing.small
    static let paddingMedium: CGFloat = Spacing.medium
    static let paddingLarge: CGFloat = Spacing.large
    static let cornerRadius: CGFloat = 8
    
    static let cardShadow = LegacyShadow(color: shadowColor, radius: 4, x: 0, y: 2)
    static let lightShadow = LegacyShadow(color: shadowColor, radius: 2, x: 0, y: 1)
    static let deepShadow = LegacyShadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
}

// MARK: - Legacy Shadow Structure
struct LegacyShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    func appBackground() -> some View {
        self.background(AppTheme.backgroundColor)
    }
    
    func cardBackground() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppTheme.cardShadow.color,
                   radius: AppTheme.cardShadow.radius,
                   x: AppTheme.cardShadow.x,
                   y: AppTheme.cardShadow.y)
    }
    
    func lightCardBackground() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppTheme.lightShadow.color,
                   radius: AppTheme.lightShadow.radius,
                   x: AppTheme.lightShadow.x,
                   y: AppTheme.lightShadow.y)
    }
    
    func vintageCardBackground() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.darkAccent.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: AppTheme.deepShadow.color,
                   radius: AppTheme.deepShadow.radius,
                   x: AppTheme.deepShadow.x,
                   y: AppTheme.deepShadow.y)
    }
    
    func mysticalTitleStyle() -> some View {
        self
            .font(AppTheme.mysticalTitle)
            .foregroundColor(AppTheme.primaryText)
            .multilineTextAlignment(.center)
    }
    
    func titleStyle() -> some View {
        self
            .font(AppTheme.title)
            .foregroundColor(AppTheme.primaryText)
            .multilineTextAlignment(.center)
    }
    
    func headlineStyle() -> some View {
        self
            .font(AppTheme.headline)
            .foregroundColor(AppTheme.primaryText)
            .multilineTextAlignment(.center)
    }
    
    func bodyStyle() -> some View {
        self
            .font(AppTheme.body)
            .foregroundColor(AppTheme.primaryText)
            .multilineTextAlignment(.leading)
    }
    
    func captionStyle() -> some View {
        self
            .font(AppTheme.caption)
            .foregroundColor(AppTheme.secondaryText)
            .multilineTextAlignment(.leading)
    }
    
    func goldTextStyle() -> some View {
        self
            .font(AppTheme.headline)
            .foregroundColor(AppTheme.goldAccent)
    }
    
    func cardPadding() -> some View {
        self.padding(AppTheme.paddingMedium)
    }
    
    func sectionPadding() -> some View {
        self.padding(AppTheme.paddingLarge)
    }
    
    func customNavigation() -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Button Styles
struct VintageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.headline)
            .foregroundColor(AppTheme.cardBackground)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(AppTheme.darkAccent)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: AppTheme.deepShadow.color,
                   radius: AppTheme.deepShadow.radius,
                   x: AppTheme.deepShadow.x,
                   y: AppTheme.deepShadow.y)
    }
}

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.headline)
            .foregroundColor(AppTheme.primaryText)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppTheme.goldAccent)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.darkAccent, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: AppTheme.cardShadow.color,
                   radius: AppTheme.cardShadow.radius,
                   x: AppTheme.cardShadow.x,
                   y: AppTheme.cardShadow.y)
    }
}

struct SecondaryVintageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.body)
            .foregroundColor(AppTheme.accentColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.accentColor, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

