import Foundation

class DataManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DataManager()
    
    // MARK: - Published Properties
    @Published var userProfile = UserProfile()
    @Published var explorationDate: Date?
    @Published var isDailyCardRevealed: Bool = false
    
    // MARK: - Private Properties
    private var cardRepository: CardRepository
    private var karmaRepository: KarmaRepository
    private var revealTracker: DailyRevealTracker
    
    // MARK: - Initialization
    private init() {
        self.cardRepository = CardRepository()
        self.karmaRepository = KarmaRepository()
        self.revealTracker = DailyRevealTracker()
        
        initializeData()
    }
    
    private func initializeData() {
        cardRepository.loadCards()
        karmaRepository.loadKarmaConnections()
        loadUserProfile()
        updateDailyRevealStatus()
    }
    
    // MARK: - Card Management
    
    func getCard(by id: Int) -> Card {
        return cardRepository.getCard(by: id)
    }
    
    func getTodayCard() -> Card {
        let targetDate = explorationDate ?? Date()
        let cardId = calculateDailyCardId(for: targetDate)
        return getCard(by: cardId)
    }
    
    private func calculateDailyCardId(for date: Date) -> Int {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return ((dayOfYear - 1) % 52) + 1
    }
    
    // MARK: - Karma Connections
    
    func getKarmaConnections(for cardId: Int) -> [KarmaConnection] {
        return karmaRepository.getConnections(for: cardId)
    }
    
    // MARK: - Daily Reveal Management
    
    func markDailyCardAsRevealed() {
        revealTracker.markAsRevealed()
        DispatchQueue.main.async {
            self.isDailyCardRevealed = true
        }
    }
    
    private func updateDailyRevealStatus() {
        isDailyCardRevealed = revealTracker.isRevealedToday()
    }
    
    // MARK: - Profile Management
    
    var isProfileComplete: Bool {
        return ProfileValidator.isComplete(userProfile)
    }
    
    func updateProfile(name: String, birthDate: Date) -> Bool {
        let validator = ProfileValidator()
        
        guard validator.validate(birthDate: birthDate) else {
            return false
        }
        
        let sanitizedName = ProfileSanitizer.sanitize(name: name)
        
        userProfile.name = sanitizedName
        userProfile.birthDate = birthDate
        saveUserProfile()
        return true
    }
    
    func saveUserProfile() {
        ProfilePersistence.save(userProfile)
    }
    
    private func loadUserProfile() {
        if let profile = ProfilePersistence.load() {
            userProfile = profile
        }
    }
}

// MARK: - Supporting Classes

private class CardRepository {
    private var cards: [Card] = []
    
    func loadCards() {
        if let loadedCards = loadCardsFromBundle() {
            cards = loadedCards
        } else {
            cards = generateFallbackCards()
        }
    }
    
    func getCard(by id: Int) -> Card {
        guard (1...52).contains(id) else {
            return cards.first { $0.id == 1 } ?? createEmergencyCard(id: 1)
        }
        
        return cards.first { $0.id == id } ?? createEmergencyCard(id: id)
    }
    
    private func loadCardsFromBundle() -> [Card]? {
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cardData = try? JSONDecoder().decode(CardData.self, from: data) else {
            return nil
        }
        return cardData.cards
    }
    
    private func generateFallbackCards() -> [Card] {
        let generator = FallbackCardGenerator()
        return generator.generateCards()
    }
    
    private func createEmergencyCard(id: Int) -> Card {
        let generator = FallbackCardGenerator()
        return generator.generateCard(for: id)
    }
}

private class KarmaRepository {
    private var primaryConnections: [String: KarmaConnection] = [:]
    private var secondaryConnections: [String: KarmaConnection] = [:]
    
    func loadKarmaConnections() {
        guard let url = Bundle.main.url(forResource: "karma_cards", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let karmaData = try? JSONDecoder().decode(KarmaData.self, from: data) else {
            resetConnections()
            return
        }
        
        primaryConnections = karmaData.karmaConnections1
        secondaryConnections = karmaData.karmaConnections2
    }
    
    func getConnections(for cardId: Int) -> [KarmaConnection] {
        guard (1...52).contains(cardId) else { return [] }
        
        let cardKey = String(cardId)
        var connections: [KarmaConnection] = []
        
        if let primary = primaryConnections[cardKey] {
            connections.append(filterValidConnection(primary))
        }
        
        if let secondary = secondaryConnections[cardKey] {
            connections.append(filterValidConnection(secondary))
        }
        
        return connections.compactMap { $0.cards.isEmpty ? nil : $0 }
    }
    
    private func filterValidConnection(_ connection: KarmaConnection) -> KarmaConnection {
        let validCards = connection.cards.filter { (1...52).contains($0) }
        return KarmaConnection(cards: validCards, description: connection.description)
    }
    
    private func resetConnections() {
        primaryConnections = [:]
        secondaryConnections = [:]
    }
}

private class DailyRevealTracker {
    private let revealDateKey = "dailyCardRevealDate"
    private let revealStatusKey = "isDailyCardRevealed"
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    func isRevealedToday() -> Bool {
        let today = dateFormatter.string(from: Date())
        let lastRevealDate = UserDefaults.standard.string(forKey: revealDateKey)
        
        if lastRevealDate == today {
            return UserDefaults.standard.bool(forKey: revealStatusKey)
        } else {
            resetRevealStatus()
            return false
        }
    }
    
    func markAsRevealed() {
        let today = dateFormatter.string(from: Date())
        UserDefaults.standard.set(today, forKey: revealDateKey)
        UserDefaults.standard.set(true, forKey: revealStatusKey)
    }
    
    private func resetRevealStatus() {
        let today = dateFormatter.string(from: Date())
        UserDefaults.standard.set(today, forKey: revealDateKey)
        UserDefaults.standard.set(false, forKey: revealStatusKey)
    }
}

private struct ProfileValidator {
    func validate(birthDate: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if date is in the future
        guard birthDate <= now else { return false }
        
        // Check if age is reasonable (not over 150 years)
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        guard let years = ageComponents.year, years <= 150 else { return false }
        
        return true
    }
    
    static func isComplete(_ profile: UserProfile) -> Bool {
        return !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct ProfileSanitizer {
    static func sanitize(name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct ProfilePersistence {
    private static let userProfileKey = "userProfile"
    
    static func save(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: userProfileKey)
        }
    }
    
    static func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: userProfileKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }
}

private class FallbackCardGenerator {
    
    private enum SuitInfo {
        case hearts, clubs, diamonds, spades
        
        var range: ClosedRange<Int> {
            switch self {
            case .hearts: return 1...13
            case .clubs: return 14...26
            case .diamonds: return 27...39
            case .spades: return 40...52
            }
        }
        
        var offset: Int {
            switch self {
            case .hearts: return 0
            case .clubs: return 13
            case .diamonds: return 26
            case .spades: return 39
            }
        }
        
        var cardSuit: CardSuit {
            switch self {
            case .hearts: return .hearts
            case .clubs: return .clubs
            case .diamonds: return .diamonds
            case .spades: return .spades
            }
        }
    }
    
    private let cardValues = ["", "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    private let faceNames = ["", "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
    
    func generateCards() -> [Card] {
        return (1...52).map { generateCard(for: $0) }
    }
    
    func generateCard(for id: Int) -> Card {
        let suitInfo = determineSuit(for: id)
        let cardIndex = id - suitInfo.offset
        
        let name = "\(faceNames[cardIndex]) of \(suitInfo.cardSuit.rawValue.capitalized)"
        let title = "The \(faceNames[cardIndex]) of \(suitInfo.cardSuit.rawValue.capitalized)"
        
        return Card(
            id: id,
            name: name,
            value: cardValues[cardIndex],
            suit: suitInfo.cardSuit,
            title: title,
            description: "Card description not available."
        )
    }
    
    private func determineSuit(for id: Int) -> SuitInfo {
        switch id {
        case SuitInfo.hearts.range: return .hearts
        case SuitInfo.clubs.range: return .clubs
        case SuitInfo.diamonds.range: return .diamonds
        case SuitInfo.spades.range: return .spades
        default: return .hearts
        }
    }
}