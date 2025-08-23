import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var userProfile = UserProfile()
    @Published var explorationDate: Date?
    @Published var isDailyCardRevealed: Bool = false
    
    private var cards: [Card] = []
    private var karmaConnections1: [String: KarmaConnection] = [:]
    private var karmaConnections2: [String: KarmaConnection] = [:]
    private var dailyCardRevealDate: String? {
        get { UserDefaults.standard.string(forKey: "dailyCardRevealDate") }
        set { UserDefaults.standard.set(newValue, forKey: "dailyCardRevealDate") }
    }

    private init() {
        loadCardData()
        loadKarmaData()
        loadUserProfile()
        checkDailyCardRevealStatus()
    }

    private func loadCardData() {
        guard let url = Bundle.main.url(forResource: "cards_base", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cardData = try? JSONDecoder().decode(CardData.self, from: data) else {
            createFallbackCards()
            return
        }

        cards = cardData.cards
    }

    private func createFallbackCards() {
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
            let faceNames = ["", "ACE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "JACK", "QUEEN", "KING"]

            let card = Card(
                id: i,
                name: "\(faceNames[cardIndex]) OF \(suit.rawValue.uppercased())",
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
            karmaConnections1 = [:]
            karmaConnections2 = [:]
            return
        }

        karmaConnections1 = karmaData.karmaConnections1
        karmaConnections2 = karmaData.karmaConnections2
    }
    
    // MARK: - Daily Card Reveal Logic
    
    private func checkDailyCardRevealStatus() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        let todayString = formatter.string(from: Date())
        
        if let lastRevealDate = dailyCardRevealDate {
            if lastRevealDate == todayString {
                // Same day, keep the revealed state
                isDailyCardRevealed = UserDefaults.standard.bool(forKey: "isDailyCardRevealed")
            } else {
                // New day, reset the state
                resetDailyCardReveal()
            }
        } else {
            // First time, reset the state
            resetDailyCardReveal()
        }
    }
    
    func markDailyCardAsRevealed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        let todayString = formatter.string(from: Date())
        
        DispatchQueue.main.async {
            self.isDailyCardRevealed = true
        }
        dailyCardRevealDate = todayString
        UserDefaults.standard.set(true, forKey: "isDailyCardRevealed")
    }
    
    private func resetDailyCardReveal() {
        isDailyCardRevealed = false
        UserDefaults.standard.set(false, forKey: "isDailyCardRevealed")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        dailyCardRevealDate = formatter.string(from: Date())
    }
    
    func getTodayCard() -> Card {
        // This should match the logic from your DailyCardViewModel
        // For now, I'll use a simple calculation based on current date
        let calendar = Calendar.current
        let now = explorationDate ?? Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let cardId = ((dayOfYear - 1) % 52) + 1
        return getCard(by: cardId)
    }

    func getCard(by id: Int) -> Card {
        guard id >= 1 && id <= 52 else {
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
        let faceNames = ["", "ACE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "JACK", "QUEEN", "KING"]

        return Card(
            id: id,
            name: "\(faceNames[cardIndex]) OF \(suit.rawValue.uppercased())",
            value: values[cardIndex],
            suit: suit,
            title: "The \(faceNames[cardIndex]) of \(suit.rawValue.capitalized)",
            description: "Card description not available."
        )
    }

    func getKarmaConnections(for cardId: Int) -> [KarmaConnection] {
        guard cardId >= 1 && cardId <= 52 else {
            return []
        }

        var connections: [KarmaConnection] = []
        let cardIdString = String(cardId)

        if let connection1 = karmaConnections1[cardIdString] {
            let validCards = connection1.cards.filter { $0 >= 1 && $0 <= 52 }
            if !validCards.isEmpty {
                connections.append(KarmaConnection(cards: validCards, description: connection1.description))
            }
        }

        if let connection2 = karmaConnections2[cardIdString] {
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

        if date > now {
            return false
        }

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

struct CardDefinition: Codable, Identifiable {
    let id: Int
    let name: String
    let value: String
    let suit: String
    let title: String
}

private struct CardDeck: Codable {
    let cards: [CardDefinition]
}

private let cardsByID: [Int: CardDefinition] = {
    guard let url = Bundle.main.url(forResource: "cards_base", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let deck = try? JSONDecoder().decode(CardDeck.self, from: data) else {
        print("⚠️ Failed to load cards_base.json")
        return [:]
    }
    return Dictionary(uniqueKeysWithValues: deck.cards.map { ($0.id, $0) })
}()

func getCardDefinition(by id: Int) -> CardDefinition? {
    cardsByID[id]
}
