import SwiftUI

struct TappableCard: View {
    let card: Card
    let size: CGSize
    let cornerRadius: CGFloat
    let action: () -> Void
    
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    init(card: Card, size: CGSize, cornerRadius: CGFloat = AppConstants.CornerRadius.cardLarge, action: @escaping () -> Void) {
        self.card = card
        self.size = size
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if let image = ImageManager.shared.loadCardImage(for: card) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: scaledSize.width, height: scaledSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .cardShadow()
            } else {
                FallbackCardView(card: card, size: scaledSize, cornerRadius: cornerRadius)
            }
        }
        .buttonStyle(AccessibleCardButtonStyle(reduceMotion: reduceMotion))
        .frame(minWidth: AppConstants.Accessibility.minimumTouchTarget,
               minHeight: AppConstants.Accessibility.minimumTouchTarget)
        .contentShape(Rectangle())
        .accessibilityLabel(cardAccessibilityLabel)
        .accessibilityHint(AppConstants.Accessibility.Hints.doubleTapToView)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("card_\(card.id)")
    }
    
    private var scaledSize: CGSize {
        guard sizeCategory.isAccessibilityCategory else { return size }
        return CGSize(width: size.width * 1.3, height: size.height * 1.3)
    }
    
    private var cardAccessibilityLabel: String {
        let valueName = cardValueName(card.value)
        return "\(valueName) of \(card.suit.rawValue)"
    }
    
    private func cardValueName(_ value: String) -> String {
        switch value.uppercased() {
        case "A": return "Ace"
        case "K": return "King"
        case "Q": return "Queen"
        case "J": return "Jack"
        default: return value
        }
    }
}

struct TappablePlanetCard: View {
    let planet: String
    let size: CGSize
    let cornerRadius: CGFloat
    let action: () -> Void
    
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    init(planet: String, size: CGSize, cornerRadius: CGFloat = AppConstants.CornerRadius.cardLarge, action: @escaping () -> Void) {
        self.planet = planet
        self.size = size
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if let image = ImageManager.shared.loadPlanetImage(for: planet) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: scaledSize.width, height: scaledSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .cardShadow()
            } else {
                FallbackPlanetView(planet: planet, size: scaledSize, cornerRadius: cornerRadius)
            }
        }
        .buttonStyle(AccessibleCardButtonStyle(reduceMotion: reduceMotion))
        .frame(minWidth: AppConstants.Accessibility.minimumTouchTarget,
               minHeight: AppConstants.Accessibility.minimumTouchTarget)
        .contentShape(Rectangle())
        .accessibilityLabel("\(planet) planetary influence")
        .accessibilityHint(AppConstants.Accessibility.Hints.doubleTapToView)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("planet_\(planet.lowercased())")
    }
    
    private var scaledSize: CGSize {
        guard sizeCategory.isAccessibilityCategory else { return size }
        return CGSize(width: size.width * 1.3, height: size.height * 1.3)
    }
}

struct CardWithLabel: View {
    let card: Card
    let label: String
    let size: CGSize
    let action: () -> Void
    
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            Text(label)
                .dynamicType(baseSize: AppConstants.FontSizes.body, textStyle: .body)
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            
            TappableCard(card: card, size: size, action: action)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(cardValueName(card.value)) of \(card.suit.rawValue)")
        .accessibilityHint(AppConstants.Accessibility.Hints.doubleTapToView)
    }
    
    private func cardValueName(_ value: String) -> String {
        switch value.uppercased() {
        case "A": return "Ace"
        case "K": return "King"
        case "Q": return "Queen"
        case "J": return "Jack"
        default: return value
        }
    }
}

struct FallbackCardView: View {
    let card: Card
    let size: CGSize
    let cornerRadius: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(Color.black, lineWidth: 2)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(red: 0.95, green: 0.88, blue: 0.72))
            )
            .frame(width: size.width, height: size.height)
            .overlay(
                VStack {
                    suitIcon(for: card.suit)
                        .accessibilityHidden(true)
                    Spacer()
                    suitIcon(for: card.suit)
                        .rotationEffect(.degrees(180))
                        .accessibilityHidden(true)
                }
                .padding(AppConstants.Spacing.small)
            )
            .cardShadow()
            .accessibilityLabel("\(card.value) of \(card.suit.rawValue)")
    }
    
    @ViewBuilder
    private func suitIcon(for suit: CardSuit) -> some View {
        switch suit {
        case .hearts:
            Image(systemName: "heart")
                .font(.title2)
                .foregroundColor(.red)
        case .clubs:
            Image(systemName: "suit.club")
                .font(.title2)
                .foregroundColor(.black)
        case .diamonds:
            Image(systemName: "diamond")
                .font(.title2)
                .foregroundColor(.red)
        case .spades:
            Image(systemName: "suit.spade")
                .font(.title2)
                .foregroundColor(.black)
        case .joker:
            Text("🃏")
                .font(.title2)
        }
    }
}

struct FallbackPlanetView: View {
    let planet: String
    let size: CGSize
    let cornerRadius: CGFloat
    
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .frame(width: size.width, height: size.height)
                .cardShadow()
            
            VStack {
                Text(planetSymbol(for: planet))
                    .font(.system(size: scaledSymbolSize))
                    .foregroundColor(.black)
                    .fontWeight(.heavy)
                    .accessibilityHidden(true)
                
                Text(planet.uppercased())
                    .dynamicType(baseSize: AppConstants.FontSizes.body, textStyle: .body)
                    .foregroundColor(.black)
                    .fontWeight(.heavy)
            }
        }
        .accessibilityLabel("\(planet) planet")
    }
    
    private var scaledSymbolSize: CGFloat {
        sizeCategory.isAccessibilityCategory ? 80 : 64
    }
    
    private func planetSymbol(for planet: String) -> String {
        switch planet.lowercased() {
        case "mercury": return "☿"
        case "venus": return "♀"
        case "mars": return "♂"
        case "jupiter": return "♃"
        case "saturn": return "♄"
        case "uranus": return "♅"
        case "neptune": return "♆"
        case "pluto": return "♇"
        default: return "●"
        }
    }
}

struct SectionHeader: View {
    let title: String
    let fontSize: CGFloat
    
    @Environment(\.sizeCategory) var sizeCategory
    
    init(_ title: String, fontSize: CGFloat = AppConstants.FontSizes.headline) {
        self.title = title
        self.fontSize = fontSize
    }
    
    var body: some View {
        Text(title)
            .dynamicType(baseSize: fontSize, textStyle: .headline)
            .fontWeight(.heavy)
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.7)
            .accessibilityAddTraits(.isHeader)
    }
}

struct LineBreak: View {
    let imageName: String
    let height: CGFloat
    
    @Environment(\.sizeCategory) var sizeCategory
    
    init(_ imageName: String = "linedesign", height: CGFloat = 20) {
        self.imageName = imageName
        self.height = height
    }
    
    var body: some View {
        Group {
            if let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: scaledHeight)
                    .decorativeImage() // Mark as decorative
            } else {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.black.opacity(0.3))
                    .decorativeImage() // Mark as decorative
            }
        }
    }
    
    private var scaledHeight: CGFloat {
        sizeCategory.isAccessibilityCategory ? height * 1.3 : height
    }
}

// AccessibleCardButtonStyle is defined in ViewModifiers.swift
