import SwiftUI

struct PlayingCardView: View {
    let card: Card
    let size: CardSize
    
    enum CardSize {
        case small, medium, large
        
        var dimensions: CGSize {
            switch self {
            case .small: return CGSize(width: 80, height: 120)
            case .medium: return CGSize(width: 120, height: 176)
            case .large: return CGSize(width: 150, height: 220)
            }
        }
    }
    
    var body: some View {
        Group {
            if let uiImage = loadCardImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.dimensions.width, height: size.dimensions.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            } else {
                textBasedCardView
            }
        }
    }
    
    private func loadCardImage() -> UIImage? {
        let imageName = card.imageName
        
        print("🃏 Trying to load image: \(imageName).png for card: \(card.name)")
        
        if let image = UIImage(named: imageName) {
            print("✅ Successfully loaded: \(imageName).png")
            return image
        }
        
        if let image = UIImage(named: "Resources/Images/\(imageName)") {
            print("✅ Successfully loaded: Resources/Images/\(imageName).png")
            return image
        }
        
        if let path = Bundle.main.path(forResource: imageName, ofType: "png", inDirectory: "Resources/Images"),
           let image = UIImage(contentsOfFile: path) {
            print("✅ Successfully loaded from path: \(path)")
            return image
        }
        
        if let path = Bundle.main.path(forResource: imageName, ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            print("✅ Successfully loaded from direct path: \(path)")
            return image
        }
        
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let files = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                let pngFiles = files.filter { $0.hasSuffix(".png") }
                print("❌ Failed to load \(imageName).png. Available PNG files: \(pngFiles.sorted())")
            }
        }
        
        print("❌ Could not find image: \(imageName).png - falling back to text display")
        return nil
    }
    
    private var textBasedCardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            
            VStack {
                HStack {
                    Text(card.value)
                        .font(.custom("Apothicaire Light Cd", size: size.fontSize))
                        .fontWeight(.heavy)
                        .foregroundColor(card.isRed ? .red : .black)
                    Spacer()
                }
                
                Spacer()
                
                Text(card.suitSymbol)
                    .font(.custom("Apothicaire Light Cd", size: size.suitSize))
                    .foregroundColor(card.isRed ? .red : .black)
                    .fontWeight(.heavy)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text(card.value)
                        .font(.custom("Apothicaire Light Cd", size: size.fontSize))
                        .fontWeight(.heavy)
                        .foregroundColor(card.isRed ? .red : .black)
                        .rotationEffect(.degrees(180))
                }
            }
            .padding(8)
        }
        .frame(width: size.dimensions.width, height: size.dimensions.height)
    }
}

extension PlayingCardView.CardSize {
    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        }
    }
    
    var suitSize: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 48
        case .large: return 64
        }
    }
}

struct CardDetailView: View {
    let card: Card
    let showDescription: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text(card.name)
                .font(.custom("Apothicaire Light Cd", size: 36))
                .fontWeight(.heavy)
                .foregroundColor(.black)
            
            Text(card.title)
                .font(.custom("Apothicaire Light Cd", size: 20))
                .fontWeight(.heavy)
                .italic()
                .foregroundColor(.black)
            
            PlayingCardView(card: card, size: .large)
            
            if showDescription {
                Text(card.description)
                    .font(.custom("Apothicaire Light Cd", size: 18))
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
            }
        }
    }
}

struct KarmaCardRow: View {
    let cards: [Card]
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(cards.count, 3)), spacing: 10) {
                ForEach(cards) { card in
                    VStack(spacing: 8) {
                        PlayingCardView(card: card, size: .small)
                        Text(card.name)
                            .font(.custom("Apothicaire Light Cd", size: 18))
                            .foregroundColor(.black)
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Text(description)
                .font(.custom("Apothicaire Light Cd", size: 18))
                .fontWeight(.heavy)
                .italic()
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
        }
    }
}

#Preview {
    let sampleCard = Card(
        id: 1,
        name: "Ace of Hearts",
        value: "A",
        suit: .hearts,
        title: "The Card of Love",
        description: "Love is your ruling force."
    )
    
    PlayingCardView(card: sampleCard, size: .large)
}