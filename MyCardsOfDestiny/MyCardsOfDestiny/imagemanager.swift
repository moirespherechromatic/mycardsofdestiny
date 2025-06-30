import UIKit
import SwiftUI

class ImageManager: ObservableObject {
    static let shared = ImageManager()
    
    private var imageCache: [String: UIImage] = [:]
    private let cacheQueue = DispatchQueue(label: "ImageCacheQueue", attributes: .concurrent)
    
    private init() {}
    
    func loadCardImage(for card: Card) -> UIImage? {
        return loadImage(named: card.imageName)
    }
    
    func loadCardImage(named imageName: String) -> UIImage? {
        return loadImage(named: imageName)
    }
    
    func loadPlanetImage(for planet: String) -> UIImage? {
        let imageName = planet.lowercased()
        return loadImage(named: imageName)
    }
    
    private func loadImage(named imageName: String) -> UIImage? {
        if let cachedImage = getCachedImage(named: imageName) {
            return cachedImage
        }
        
        let image = attemptImageLoad(named: imageName)
        setCachedImage(image, named: imageName)
        return image
    }
    
    private func attemptImageLoad(named imageName: String) -> UIImage? {
        let namesToTry = [
            imageName,
            imageName.uppercased(),
            "\(imageName).png",
            "\(imageName.uppercased()).png",
            "Resources/Images/\(imageName)",
            "Resources/Images/\(imageName.uppercased())",
            "card_\(imageName)",
            "Card_\(imageName)"
        ]
        
        for name in namesToTry {
            if let image = UIImage(named: name) {
                return image
            }
        }
        
        if let path = Bundle.main.path(forResource: imageName, ofType: "png", inDirectory: "Resources/Images"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        
        return nil
    }
    
    private func getCachedImage(named imageName: String) -> UIImage? {
        return cacheQueue.sync {
            return imageCache[imageName]
        }
    }
    
    private func setCachedImage(_ image: UIImage?, named imageName: String) {
        cacheQueue.async(flags: .barrier) {
            self.imageCache[imageName] = image
        }
    }
    
    func clearCache() {
        cacheQueue.async(flags: .barrier) {
            self.imageCache.removeAll()
        }
    }
    
    struct CachedImage: View {
        let imageName: String
        let width: CGFloat?
        let height: CGFloat?
        let cornerRadius: CGFloat
        
        init(_ imageName: String, width: CGFloat? = nil, height: CGFloat? = nil, cornerRadius: CGFloat = 12) {
            self.imageName = imageName
            self.width = width
            self.height = height
            self.cornerRadius = cornerRadius
        }
        
        var body: some View {
            Group {
                if let image = ImageManager.shared.loadImage(named: imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width, height: height)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: width, height: height)
                        .overlay(
                            VStack {
                                Text("Missing:")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                                Text(imageName)
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.black)
                            }
                        )
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                }
            }
        }
    }
    
    struct CachedCardImage: View {
        let card: Card
        let width: CGFloat?
        let height: CGFloat?
        let cornerRadius: CGFloat
        
        init(card: Card, width: CGFloat? = nil, height: CGFloat? = nil, cornerRadius: CGFloat = 12) {
            self.card = card
            self.width = width
            self.height = height
            self.cornerRadius = cornerRadius
        }
        
        var body: some View {
            CachedImage(card.imageName, width: width, height: height, cornerRadius: cornerRadius)
        }
    }
}