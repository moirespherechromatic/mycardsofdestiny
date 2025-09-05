import SwiftUI
import UIKit

struct ShareCardContent: Identifiable, Hashable {
    var id: UUID = .init()
    var title: String
    var subtitle: String
    var excerpt: String
    var date: Date
    var image: Image
    
    static func == (lhs: ShareCardContent, rhs: ShareCardContent) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ShareCardExportSize: CaseIterable {
    case portrait1080x1350
    case square1200
    case story1080x1920
    
    var dimensions: CGSize {
        switch self {
        case .portrait1080x1350:
            return CGSize(width: 1080, height: 1350)
        case .square1200:
            return CGSize(width: 1200, height: 1200)
        case .story1080x1920:
            return CGSize(width: 1080, height: 1920)
        }
    }
    
    var aspectRatio: CGFloat {
        let size = dimensions
        return size.width / size.height
    }
}

struct ShareCardView: View {
    let content: ShareCardContent
    let exportSize: ShareCardExportSize
    
    private let inkColor = Color.black
    private let backgroundColor = Color(red: 0.86, green: 0.77, blue: 0.57)
    
    init(content: ShareCardContent, exportSize: ShareCardExportSize = .portrait1080x1350) {
        self.content = content
        self.exportSize = exportSize
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(backgroundColor)
                
                ScrollView {
                    VStack(spacing: 0) {
                        cardImageSection(in: geometry)
                        contentSection(in: geometry)
                        footerSection(in: geometry)
                    }
                    .padding(30)
                }
                .scrollIndicators(.hidden)
            }
        }
        .aspectRatio(exportSize.aspectRatio, contentMode: .fit)
    }
    
    private func cardImageSection(in geometry: GeometryProxy) -> some View {
        let availableWidth = max(200, geometry.size.width - 60)
        let imageHeight = max(200, min(availableWidth * 0.6, 300))
        let imageWidth = max(160, availableWidth * 0.7)
        
        return content.image
            .resizable()
            .aspectRatio(16/20, contentMode: .fit)
            .frame(width: imageWidth, height: imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.bottom, dynamicSpacing(base: 25, geometry: geometry))
    }
    
    private func contentSection(in geometry: GeometryProxy) -> some View {
        VStack(spacing: dynamicSpacing(base: 15, geometry: geometry)) {
            Text(content.title.uppercased())
                .font(titleFont(for: geometry))
                
                .foregroundColor(inkColor)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            
            Text(content.subtitle.lowercased())
                .font(subtitleFont(for: geometry))
                
                .foregroundColor(inkColor)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
            
            Rectangle()
                .frame(width: 80, height: 1)
                .foregroundColor(inkColor.opacity(0.6))
                .padding(.vertical, dynamicSpacing(base: 8, geometry: geometry))
            
            Text(content.excerpt)
                .font(bodyFont(for: geometry))
                .foregroundColor(inkColor)
                
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, dynamicSpacing(base: 25, geometry: geometry))
    }
    
    private func footerSection(in geometry: GeometryProxy) -> some View {
        HStack {
            Text(formattedDate)
                .font(footerFont(for: geometry))
                .foregroundColor(inkColor.opacity(0.7))
            
            Spacer()
        }
        .padding(.top, dynamicSpacing(base: 30, geometry: geometry))
    }
    
    private func dynamicSpacing(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let scale = min(geometry.size.width, geometry.size.height) / 500.0
        return base * max(0.8, min(1.8, scale))
    }
    
    private func titleFont(for geometry: GeometryProxy) -> Font {
        let baseSize: CGFloat = 32
        let scaledSize = baseSize * fontScale(for: geometry)
        return .custom("Iowan Old Style", size: scaledSize)
    }
    
    private func subtitleFont(for geometry: GeometryProxy) -> Font {
        let baseSize: CGFloat = 22
        let scaledSize = baseSize * fontScale(for: geometry)
        return .custom("Iowan Old Style", size: scaledSize)
    }
    
    private func bodyFont(for geometry: GeometryProxy) -> Font {
        let baseSize: CGFloat = 18
        let scaledSize = baseSize * fontScale(for: geometry)
        return .custom("Iowan Old Style", size: scaledSize)
    }
    
    private func footerFont(for geometry: GeometryProxy) -> Font {
        let baseSize: CGFloat = 14
        let scaledSize = baseSize * fontScale(for: geometry)
        return .custom("Iowan Old Style", size: scaledSize)
    }
    
    private func fontScale(for geometry: GeometryProxy) -> CGFloat {
        let scale = min(geometry.size.width, geometry.size.height) / 500.0
        return max(0.8, min(1.6, scale))
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: content.date)
    }
}

enum ShareCardRenderer {
    static func renderPNG(content: ShareCardContent, size: ShareCardExportSize) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                do {
                    let shareView = ShareCardView(content: content, exportSize: size)
                    let renderer = ImageRenderer(content: shareView)
                    
                    renderer.proposedSize = .init(size.dimensions)
                    renderer.scale = 1.0
                    
                    guard let uiImage = renderer.uiImage else {
                        continuation.resume(throwing: ShareCardError.renderingFailed)
                        return
                    }
                    
                    let tempDirectory = FileManager.default.temporaryDirectory
                    let filename = "sharecard_\(content.id.uuidString).png"
                    let fileURL = tempDirectory.appendingPathComponent(filename)
                    
                    guard let pngData = uiImage.pngData() else {
                        continuation.resume(throwing: ShareCardError.pngConversionFailed)
                        return
                    }
                    
                    try pngData.write(to: fileURL)
                    continuation.resume(returning: fileURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum ShareCardError: LocalizedError {
    case renderingFailed
    case pngConversionFailed
    
    var errorDescription: String? {
        switch self {
        case .renderingFailed:
            return "Failed to render share card"
        case .pngConversionFailed:
            return "Failed to convert to PNG"
        }
    }
}

struct ShareCardShareLink: View {
    let content: ShareCardContent
    let size: ShareCardExportSize
    
    @State private var isSharing = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init(content: ShareCardContent, size: ShareCardExportSize = .portrait1080x1350) {
        self.content = content
        self.size = size
    }
    
    var body: some View {
        Button(action: shareCard) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .frame(width: 44, height: 44)
            } else {
                if let shareIcon = UIImage(named: "share_icon") {
                    Image(uiImage: shareIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
        }
        .disabled(isLoading)
        .accessibilityLabel("Share")
        .sheet(isPresented: $isSharing) {
            ShareSheet(content: content, size: size)
        }
        .alert("Share Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func shareCard() {
        isLoading = true
        Task {
            do {
                try await Task.sleep(nanoseconds: 200_000_000)
                await MainActor.run {
                    isLoading = false
                    isSharing = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let content: ShareCardContent
    let size: ShareCardExportSize
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let textContent = generateTextContent()
        let activityVC = UIActivityViewController(activityItems: [textContent], applicationActivities: nil)
        
        Task {
            do {
                let imageURL = try await ShareCardRenderer.renderPNG(content: content, size: size)
                await MainActor.run {
                    let newItems = [imageURL, textContent]
                    activityVC.setValue(newItems, forKey: "activityItems")
                }
            } catch {
                print("Failed to generate share image: \(error)")
            }
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    private func generateTextContent() -> String {
        var text = "\(content.title): \(content.subtitle)"
        text += " — \(DateFormatter.shortDate.string(from: content.date))\n\n"
        
        let excerptLimit = 200
        if content.excerpt.count > excerptLimit {
            let truncated = String(content.excerpt.prefix(excerptLimit))
            text += truncated + "..."
        } else {
            text += content.excerpt
        }
        
        return text
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

extension ShareCardContent {
    static func fromModal(
        card: Card,
        cardType: CardType,
        contentType: DetailContentType?,
        date: Date = Date()
    ) -> ShareCardContent {
        
        var cardName = ""
        var cardTitle = ""
        var description = ""
        var image: Image = Image(systemName: "questionmark.card")
        
        if case .planetary(let planet) = contentType {
            let planetInfo = AppConstants.PlanetDescriptions.getDescription(for: planet)
            cardName = planet.uppercased()
            cardTitle = planetInfo.title
            description = planetInfo.description
            
            if let planetImage = ImageManager.shared.loadPlanetImage(for: planet) {
                image = Image(uiImage: planetImage)
            }
        } else {
            if let def = getCardDefinition(by: card.id) {
                cardName = def.name
                cardTitle = def.title
            }
            
            if let cardImage = ImageManager.shared.loadCardImage(for: card) {
                image = Image(uiImage: cardImage)
            }
            
            let repo = DescriptionRepository.shared
            let cardID = String(card.id)
            
            switch contentType {
            case .karma(let karmaDescription):
                description = karmaDescription
            default:
                switch cardType {
                case .daily:
                    description = repo.dailyDescriptions[cardID] ?? "No daily description available."
                case .birth:
                    description = repo.birthDescriptions[cardID] ?? "No birth description available."
                case .yearly:
                    description = repo.yearlyDescriptions[cardID] ?? "No yearly description available."
                case .fiftyTwoDay:
                    description = repo.fiftyTwoDescriptions[cardID] ?? "No 52-day description available."
                case .planetary:
                    description = "Error: Should be handled above"
                }
            }
        }
        
        return ShareCardContent(
            title: cardName,
            subtitle: cardTitle,
            excerpt: description,
            date: date,
            image: image
        )
    }
}
