import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var userProfile = UserProfile()
    @Published var explorationDate: Date?
    private var cards: [Card] = []
    private var karmaConnections1: [String: KarmaConnection] = [:]
    private var karmaConnections2: [String: KarmaConnection] = [:]

    private init() {
        loadCardData()
        loadKarmaData()
        loadUserProfile()
    }

    // MARK: - Card Data
    private func loadCardData() {
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cardData = try? JSONDecoder().decode(CardData.self, from: data) else {
            print("Failed to load cards.json - creating fallback cards")
            createFallbackCards()
            return
        }

        cards = cardData.cards
    }

    private func createFallbackCards() {
        // Fallback card creation if JSON fails
        for i in 1...52 {
            let suit: CardSuit
            let suitOffset: Int

            switch i {
            case 1...13:
                suit = .hearts
                suitOffset = 0
            case 14...26:
                suit = .clubs
                suitOffset = 13
            case 27...39:
                suit = .diamonds
                suitOffset = 26
            case 40...52:
                suit = .spades
                suitOffset = 39
            default:
                suit = .hearts
                suitOffset = 0
            }

            let cardIndex = i - suitOffset
            let values = ["", "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
            let faceNames = ["", "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]

            let card = Card(
                id: i,
                name: "\(faceNames[cardIndex]) of \(suit.rawValue.capitalized)",
                value: values[cardIndex],
                suit: suit,
                title: "The \(faceNames[cardIndex]) of \(suit.rawValue.capitalized)",
                description: "No description available."
            )
            cards.append(card)
        }
    }

    private func loadKarmaData() {
        guard let url = Bundle.main.url(forResource: "karma_cards", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let karmaData = try? JSONDecoder().decode(KarmaData.self, from: data) else {
            print("Failed to load karma_cards.json - using empty karma connections")
            karmaConnections1 = [:]
            karmaConnections2 = [:]
            return
        }

        karmaConnections1 = karmaData.karmaConnections1
        karmaConnections2 = karmaData.karmaConnections2
    }

    // MARK: - Public Methods
    func getCard(by id: Int) -> Card {
        // Validate ID range
        guard id >= 1 && id <= 52 else {
            print("ERROR: Invalid card ID: \(id), returning Ace of Hearts")
            return cards.first { $0.id == 1 } ?? createFallbackCard(id: 1)
        }

        return cards.first { $0.id == id } ?? createFallbackCard(id: id)
    }

    private func createFallbackCard(id: Int) -> Card {
        let suit: CardSuit
        let suitOffset: Int

        switch id {
        case 1...13:
            suit = .hearts
            suitOffset = 0
        case 14...26:
            suit = .clubs
            suitOffset = 13
        case 27...39:
            suit = .diamonds
            suitOffset = 26
        case 40...52:
            suit = .spades
            suitOffset = 39
        default:
            suit = .hearts
            suitOffset = 0
        }

        let cardIndex = id - suitOffset
        let values = ["", "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        let faceNames = ["", "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]

        return Card(
            id: id,
            name: "\(faceNames[cardIndex]) of \(suit.rawValue.capitalized)",
            value: values[cardIndex],
            suit: suit,
            title: "The \(faceNames[cardIndex]) of \(suit.rawValue.capitalized)",
            description: "Card description not available."
        )
    }

    func getKarmaConnections(for cardId: Int) -> [KarmaConnection] {
        guard cardId >= 1 && cardId <= 52 else {
            print("ERROR: Invalid card ID for karma connections: \(cardId)")
            return []
        }

        var connections: [KarmaConnection] = []
        let cardIdString = String(cardId)

        if let connection1 = karmaConnections1[cardIdString] {
            // Validate karma card IDs
            let validCards = connection1.cards.filter { $0 >= 1 && $0 <= 52 }
            if !validCards.isEmpty {
                connections.append(KarmaConnection(cards: validCards, description: connection1.description))
            }
        }

        if let connection2 = karmaConnections2[cardIdString] {
            // Validate karma card IDs
            let validCards = connection2.cards.filter { $0 >= 1 && $0 <= 52 }
            if !validCards.isEmpty {
                connections.append(KarmaConnection(cards: validCards, description: connection2.description))
            }
        }

        return connections
    }

    func validateBirthDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        // Check if birth date is in the future
        if date > now {
            return false
        }

        // Check if person would be over 150 years old
        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        if let years = ageComponents.year, years > 150 {
            return false
        }

        return true
    }

    func updateProfile(name: String, birthDate: Date) -> Bool {
        guard validateBirthDate(birthDate) else {
            return false
        }

        userProfile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        userProfile.birthDate = birthDate
        saveUserProfile()
        return true
    }

    // MARK: - User Profile Management
    func saveUserProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
    }

    private func loadUserProfile() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
    }

    var isProfileComplete: Bool {
        !userProfile.name.isEmpty
    }
}
