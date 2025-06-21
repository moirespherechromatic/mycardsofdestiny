import SwiftUI

// MARK: - Reusable Card Components

struct TappableCard: View {
    let card: Card
    let size: CGSize
    let cornerRadius: CGFloat
    let action: () -> Void
    
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
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .cardShadow()
            } else {
                FallbackCardView(card: card, size: size, cornerRadius: cornerRadius)
            }
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct TappablePlanetCard: View {
    let planet: String
    let size: CGSize
    let cornerRadius: CGFloat
    let action: () -> Void
    
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
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .cardShadow()
            } else {
                FallbackPlanetView(planet: planet, size: size, cornerRadius: cornerRadius)
            }
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct CardWithLabel: View {
    let card: Card
    let label: String
    let size: CGSize
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            Text(label)
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            TappableCard(card: card, size: size, action: action)
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
                    Spacer()
                    suitIcon(for: card.suit)
                        .rotationEffect(.degrees(180))
                }
                .padding(AppConstants.Spacing.small)
            )
            .cardShadow()
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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .frame(width: size.width, height: size.height)
                .cardShadow()
            
            VStack {
                Text(planetSymbol(for: planet))
                    .font(.custom("Apothicaire Light Cd", size: 64))
                    .foregroundColor(.black)
                    .fontWeight(.heavy)
                
                Text(planet.uppercased())
                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
                    .foregroundColor(.black)
                    .fontWeight(.heavy)
            }
        }
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
    
    init(_ title: String, fontSize: CGFloat = AppConstants.FontSizes.headline) {
        self.title = title
        self.fontSize = fontSize
    }
    
    var body: some View {
        Text(title)
            .font(.custom("Apothicaire Light Cd", size: fontSize))
            .fontWeight(.heavy)
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
    }
}

struct LineBreak: View {
    let imageName: String
    let height: CGFloat
    
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
                    .frame(height: height)
            } else {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.black.opacity(0.3))
            }
        }
    }
}