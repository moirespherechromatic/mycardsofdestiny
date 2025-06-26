import Foundation

class BirthCardLookup {
    
    // MARK: - Singleton
    static let shared = BirthCardLookup()
    
    // MARK: - Types
    
    private struct DateCard {
        let month: Int
        let day: Int
        let cardId: Int
        
        var dateKey: String {
            return "\(month)-\(day)"
        }
    }
    
    private struct MonthInfo {
        let monthNumber: Int
        let daysInMonth: Int
        
        static let yearInfo: [MonthInfo] = [
            MonthInfo(monthNumber: 1, daysInMonth: 31),   // January
            MonthInfo(monthNumber: 2, daysInMonth: 29),   // February (leap year)
            MonthInfo(monthNumber: 3, daysInMonth: 31),   // March
            MonthInfo(monthNumber: 4, daysInMonth: 30),   // April
            MonthInfo(monthNumber: 5, daysInMonth: 31),   // May
            MonthInfo(monthNumber: 6, daysInMonth: 30),   // June
            MonthInfo(monthNumber: 7, daysInMonth: 31),   // July
            MonthInfo(monthNumber: 8, daysInMonth: 31),   // August
            MonthInfo(monthNumber: 9, daysInMonth: 30),   // September
            MonthInfo(monthNumber: 10, daysInMonth: 31),  // October
            MonthInfo(monthNumber: 11, daysInMonth: 30),  // November
            MonthInfo(monthNumber: 12, daysInMonth: 31)   // December
        ]
    }
    
    // MARK: - Properties
    
    private var dateToCardCache: [String: Int] = [:]
    private var cardToDateCache: [Int: [DateCard]] = [:]
    private let calculator = BirthCardCalculator()
    
    // MARK: - Initialization
    
    private init() {
        initializeLookupSystem()
    }
    
    // MARK: - Public Methods
    
    func getBirthCard(month: Int, day: Int) -> Int {
        guard DateValidator.isValid(month: month, day: day) else {
            return BirthCardCalculator.Constants.fallbackCardId
        }
        
        let dateKey = DateCard(month: month, day: day, cardId: 0).dateKey
        
        if let cachedCard = dateToCardCache[dateKey] {
            return cachedCard
        }
        
        return calculator.calculateCard(month: month, day: day)
    }
    
    func getBirthCard(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: date)
        
        guard let month = components.month, let day = components.day else {
            return BirthCardCalculator.Constants.fallbackCardId
        }
        
        return getBirthCard(month: month, day: day)
    }
    
    func getDatesForCard(_ cardId: Int) -> [(month: Int, day: Int)] {
        guard CardValidator.isValidCard(cardId) else { return [] }
        
        return cardToDateCache[cardId]?.map { dateCard in
            (month: dateCard.month, day: dateCard.day)
        } ?? []
    }
    
    func isValidBirthDate(month: Int, day: Int) -> Bool {
        return DateValidator.isValid(month: month, day: day) && 
               dateToCardCache.keys.contains(DateCard(month: month, day: day, cardId: 0).dateKey)
    }
    
    func getAllValidDateCards() -> [(month: Int, day: Int, cardId: Int)] {
        return dateToCardCache
            .compactMap { (key, cardId) -> (Int, Int, Int)? in
                let components = key.split(separator: "-")
                guard components.count == 2,
                      let month = Int(components[0]),
                      let day = Int(components[1]) else {
                    return nil
                }
                return (month, day, cardId)
            }
            .sorted { first, second in
                if first.0 == second.0 {
                    return first.1 < second.1
                }
                return first.0 < second.0
            }
    }
    
    // MARK: - Private Methods
    
    private func initializeLookupSystem() {
        let builder = LookupTableBuilder(calculator: calculator)
        let lookupTables = builder.buildTables()
        
        self.dateToCardCache = lookupTables.dateToCard
        self.cardToDateCache = lookupTables.cardToDate
    }
}

// MARK: - Supporting Classes

private struct BirthCardCalculator {
    
    struct Constants {
        static let baseValue = 55
        static let monthMultiplier = 2
        static let fallbackCardId = 1
        static let maxCardId = 52
    }
    
    func calculateCard(month: Int, day: Int) -> Int {
        let rawCalculation = Constants.baseValue - (month * Constants.monthMultiplier + day)
        
        // Ensure result is within valid range
        if rawCalculation <= 0 || rawCalculation > Constants.maxCardId {
            return Constants.fallbackCardId
        }
        
        return rawCalculation
    }
}

private struct DateValidator {
    static func isValid(month: Int, day: Int) -> Bool {
        guard (1...12).contains(month) else { return false }
        
        let monthInfo = MonthInfo.yearInfo.first { $0.monthNumber == month }
        guard let daysInMonth = monthInfo?.daysInMonth else { return false }
        
        return (1...daysInMonth).contains(day)
    }
}

private struct CardValidator {
    static func isValidCard(_ cardId: Int) -> Bool {
        return (1...52).contains(cardId)
    }
}

private class LookupTableBuilder {
    
    private let calculator: BirthCardCalculator
    
    init(calculator: BirthCardCalculator) {
        self.calculator = calculator
    }
    
    struct LookupTables {
        let dateToCard: [String: Int]
        let cardToDate: [Int: [BirthCardLookup.DateCard]]
    }
    
    func buildTables() -> LookupTables {
        var dateToCardMap: [String: Int] = [:]
        var cardToDateMap: [Int: [BirthCardLookup.DateCard]] = [:]
        
        // Initialize card arrays
        for cardId in 1...52 {
            cardToDateMap[cardId] = []
        }
        
        // Process all valid dates
        for monthInfo in MonthInfo.yearInfo {
            processMonth(
                monthInfo,
                dateToCardMap: &dateToCardMap,
                cardToDateMap: &cardToDateMap
            )
        }
        
        return LookupTables(
            dateToCard: dateToCardMap,
            cardToDate: cardToDateMap
        )
    }
    
    private func processMonth(
        _ monthInfo: MonthInfo,
        dateToCardMap: inout [String: Int],
        cardToDateMap: inout [Int: [BirthCardLookup.DateCard]]
    ) {
        for day in 1...monthInfo.daysInMonth {
            let cardId = calculator.calculateCard(
                month: monthInfo.monthNumber,
                day: day
            )
            
            let dateCard = BirthCardLookup.DateCard(
                month: monthInfo.monthNumber,
                day: day,
                cardId: cardId
            )
            
            // Update mappings
            dateToCardMap[dateCard.dateKey] = cardId
            cardToDateMap[cardId]?.append(dateCard)
        }
    }
}

// MARK: - Extensions

extension BirthCardLookup {
    
    /// Provides additional analysis methods for birth card data
    struct Analytics {
        
        static func getCardFrequency() -> [Int: Int] {
            let lookup = BirthCardLookup.shared
            var frequency: [Int: Int] = [:]
            
            for cardId in 1...52 {
                let dates = lookup.getDatesForCard(cardId)
                frequency[cardId] = dates.count
            }
            
            return frequency
        }
        
        static func getMostCommonCards() -> [Int] {
            let frequency = getCardFrequency()
            let maxCount = frequency.values.max() ?? 0
            
            return frequency
                .filter { $0.value == maxCount }
                .map { $0.key }
                .sorted()
        }
        
        static func getLeastCommonCards() -> [Int] {
            let frequency = getCardFrequency()
            let minCount = frequency.values.min() ?? 0
            
            return frequency
                .filter { $0.value == minCount }
                .map { $0.key }
                .sorted()
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension BirthCardLookup {
    
    func validateLookupTables() -> Bool {
        // Verify all date-to-card mappings are consistent
        for (dateKey, cardId) in dateToCardCache {
            let components = dateKey.split(separator: "-")
            guard components.count == 2,
                  let month = Int(components[0]),
                  let day = Int(components[1]) else {
                continue
            }
            
            let calculatedCard = calculator.calculateCard(month: month, day: day)
            if calculatedCard != cardId {
                print("Lookup table inconsistency: \(dateKey) -> \(cardId) vs calculated \(calculatedCard)")
                return false
            }
        }
        
        return true
    }
    
    func printStatistics() {
        let frequency = Analytics.getCardFrequency()
        let total = frequency.values.reduce(0, +)
        
        print("Birth Card Lookup Statistics:")
        print("Total date entries: \(total)")
        print("Unique cards: \(frequency.keys.count)")
        print("Most common cards: \(Analytics.getMostCommonCards())")
        print("Least common cards: \(Analytics.getLeastCommonCards())")
    }
}
#endif