import Foundation

class BirthCardLookup {
    static let shared = BirthCardLookup()
    
    private var dateToCardMap: [String: Int] = [:]
    private var cardToDateMap: [Int: [(month: Int, day: Int)]] = [:]
    
    private init() {
        buildLookupTables()
    }
    
    private func buildLookupTables() {
        let daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        
        for month in 1...12 {
            for day in 1...daysInMonth[month - 1] {
                let cardId = calculateBirthCard(month: month, day: day)
                let key = "\(month)-\(day)"
                
                dateToCardMap[key] = cardId
                
                if cardToDateMap[cardId] == nil {
                    cardToDateMap[cardId] = []
                }
                cardToDateMap[cardId]?.append((month: month, day: day))
            }
        }
    }
    
    func getBirthCard(month: Int, day: Int) -> Int {
        guard month >= 1 && month <= 12 && day >= 1 && day <= 31 else {
            return 1
        }
        
        let key = "\(month)-\(day)"
        return dateToCardMap[key] ?? calculateBirthCard(month: month, day: day)
    }
    
    func getBirthCard(for date: Date) -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return getBirthCard(month: month, day: day)
    }
    
    func getDatesForCard(_ cardId: Int) -> [(month: Int, day: Int)] {
        return cardToDateMap[cardId] ?? []
    }
    
    func isValidBirthDate(month: Int, day: Int) -> Bool {
        let key = "\(month)-\(day)"
        return dateToCardMap[key] != nil
    }
    
    private func calculateBirthCard(month: Int, day: Int) -> Int {
        let result = 55 - ((month * 2) + day)
        return max(1, min(52, result == 0 ? 1 : result))
    }
    
    func getAllValidDateCards() -> [(month: Int, day: Int, cardId: Int)] {
        return dateToCardMap.compactMap { key, cardId in
            let components = key.split(separator: "-")
            guard components.count == 2,
                  let month = Int(components[0]),
                  let day = Int(components[1]) else {
                return nil
            }
            return (month: month, day: day, cardId: cardId)
        }.sorted { $0.month < $1.month || ($0.month == $1.month && $0.day < $1.day) }
    }
}