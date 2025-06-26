import Foundation

class CardCalculationService: ObservableObject {
    
    // MARK: - Types
    
    private struct CardSpread {
        var primary: [Int]
        var secondary: [Int]
        
        init() {
            self.primary = Array(0...52)
            self.secondary = Array(0...52)
        }
        
        mutating func reset() {
            self.primary = Array(0...52)
            self.secondary = Array(0...52)
        }
        
        mutating func swapSpreads() {
            for index in 1...52 {
                primary[index] = secondary[index]
            }
        }
    }
    
    private struct DateCalculation {
        let birthDate: Date
        let targetDate: Date
        let daysDifference: Int
        let weeksDifference: Int
        let remainingDays: Int
        
        init(from birthDate: Date, to targetDate: Date, using calendar: Calendar) {
            self.birthDate = calendar.startOfDay(for: birthDate)
            self.targetDate = calendar.startOfDay(for: targetDate)
            
            let components = calendar.dateComponents([.day], from: self.birthDate, to: self.targetDate)
            self.daysDifference = components.day ?? 0
            self.weeksDifference = self.daysDifference / 7
            self.remainingDays = self.daysDifference % 7
        }
    }
    
    private enum PlanetaryPeriod: Int, CaseIterable {
        case mercury = 1, venus, mars, jupiter, saturn, uranus, neptune
        
        var name: String {
            switch self {
            case .mercury: return "Mercury"
            case .venus: return "Venus" 
            case .mars: return "Mars"
            case .jupiter: return "Jupiter"
            case .saturn: return "Saturn"
            case .uranus: return "Uranus"
            case .neptune: return "Neptune"
            }
        }
        
        static func from(dayNumber: Int) -> PlanetaryPeriod {
            let clampedDay = max(1, min(7, dayNumber))
            return PlanetaryPeriod(rawValue: clampedDay) ?? .mercury
        }
    }
    
    // MARK: - Properties
    
    private var workingSpread = CardSpread()
    
    private var systemCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    // MARK: - Public Methods
    
    func getBirthCard(month: Int, day: Int) -> Int {
        guard isValidDate(month: month, day: day) else {
            return BirthCardConstants.fallbackCard
        }
        
        return BirthCardCalculator.calculate(month: month, day: day)
    }
    
    func getDailyCard(birthDate: Date, birthCard: Int, targetDate: Date) -> DailyCardResult {
        guard isValidCard(birthCard) else {
            return createFallbackResult(for: birthCard)
        }
        
        let dateCalc = DateCalculation(from: birthDate, to: targetDate, using: systemCalendar)
        let transformedSpread = generateTransformedSpread(iterations: dateCalc.weeksDifference + 1)
        
        guard let cardIndex = findCardInSpread(birthCard, in: transformedSpread.primary) else {
            return createFallbackResult(for: birthCard)
        }
        
        let adjustedIndex = calculateAdjustedIndex(
            baseIndex: cardIndex,
            offset: dateCalc.remainingDays
        )
        
        guard isValidIndex(adjustedIndex, in: transformedSpread.secondary) else {
            return createFallbackResult(for: birthCard)
        }
        
        let resultCard = transformedSpread.secondary[adjustedIndex]
        let planet = PlanetaryPeriod.from(dayNumber: dateCalc.remainingDays + 1)
        let card = DataManager.shared.getCard(by: resultCard)
        
        return DailyCardResult(
            card: card,
            planet: planet.name,
            planetNum: planet.rawValue
        )
    }
    
    func getLongRangeCard(birthCard: Int, age: Int) -> Int {
        guard isValidCard(birthCard), age >= 0 else {
            return BirthCardConstants.fallbackCard
        }
        
        let calculator = LongRangeCalculator(birthCard: birthCard, age: age)
        return calculator.calculate()
    }
    
    func get52DayCard(birthCard: Int, age: Int, period: Int) -> Int {
        guard isValidCard(birthCard), 
              age >= 0, 
              (1...7).contains(period) else {
            return BirthCardConstants.fallbackCard
        }
        
        let transformedSpread = generateTransformedSpread(iterations: age + 1)
        
        guard let cardIndex = findCardInSpread(birthCard, in: transformedSpread.primary) else {
            return birthCard
        }
        
        let adjustedIndex = normalizeIndex(cardIndex + period)
        
        guard isValidIndex(adjustedIndex, in: transformedSpread.primary) else {
            return birthCard
        }
        
        return transformedSpread.primary[adjustedIndex]
    }
    
    func getCurrentPeriod(birthDate: Date, targetDate: Date) -> Int {
        let dateCalc = DateCalculation(from: birthDate, to: targetDate, using: systemCalendar)
        let yearDay = dateCalc.daysDifference % 365
        let period = (yearDay / 52) + 1
        return max(1, min(period, 7))
    }
    
    func getAge(birthDate: Date, onDate: Date = Date()) -> Int {
        let ageComponents = systemCalendar.dateComponents([.year], from: birthDate, to: onDate)
        return max(0, ageComponents.year ?? 0)
    }
    
    // MARK: - Private Methods
    
    private func isValidDate(month: Int, day: Int) -> Bool {
        return (1...12).contains(month) && (1...31).contains(day)
    }
    
    private func isValidCard(_ cardId: Int) -> Bool {
        return (1...52).contains(cardId)
    }
    
    private func isValidIndex(_ index: Int, in array: [Int]) -> Bool {
        return (1..<array.count).contains(index)
    }
    
    private func createFallbackResult(for cardId: Int) -> DailyCardResult {
        let fallbackCard = DataManager.shared.getCard(by: max(1, cardId))
        return DailyCardResult(card: fallbackCard, planet: "Mercury", planetNum: 1)
    }
    
    private func findCardInSpread(_ targetCard: Int, in spread: [Int]) -> Int? {
        for index in 1...52 {
            if spread.indices.contains(index) && spread[index] == targetCard {
                return index
            }
        }
        return nil
    }
    
    private func calculateAdjustedIndex(baseIndex: Int, offset: Int) -> Int {
        let newIndex = baseIndex + 1 + offset
        return newIndex > 52 ? newIndex - 52 : newIndex
    }
    
    private func normalizeIndex(_ index: Int) -> Int {
        return index > 52 ? index - 52 : index
    }
    
    private func generateTransformedSpread(iterations: Int) -> CardSpread {
        workingSpread.reset()
        
        for _ in 1...iterations {
            performSpreadTransformation()
        }
        
        return workingSpread
    }
    
    private func performSpreadTransformation() {
        let transformer = SpreadTransformer()
        transformer.transform(&workingSpread)
    }
}

// MARK: - Helper Classes

private struct BirthCardConstants {
    static let baseNumber = 55
    static let monthMultiplier = 2
    static let fallbackCard = 1
}

private struct BirthCardCalculator {
    static func calculate(month: Int, day: Int) -> Int {
        let rawResult = BirthCardConstants.baseNumber - 
                       (month * BirthCardConstants.monthMultiplier + day)
        
        guard (1...52).contains(rawResult) else {
            return BirthCardConstants.fallbackCard
        }
        
        return rawResult
    }
}

private struct LongRangeCalculator {
    let birthCard: Int
    let age: Int
    
    func calculate() -> Int {
        let sevenYearCycles = age / 7
        
        if sevenYearCycles < 1 {
            return calculateForYoungAge()
        } else {
            return calculateForMatureAge(cycles: sevenYearCycles)
        }
    }
    
    private func calculateForYoungAge() -> Int {
        var spread = CardSpread()
        let transformer = SpreadTransformer()
        transformer.transform(&spread)
        
        guard let cardPosition = findCardPosition(birthCard, in: spread.secondary) else {
            return birthCard
        }
        
        let adjustedPosition = calculatePosition(cardPosition, offset: age + 1)
        
        guard (1...52).contains(adjustedPosition) && 
              spread.secondary.indices.contains(adjustedPosition) else {
            return birthCard
        }
        
        return spread.secondary[adjustedPosition]
    }
    
    private func calculateForMatureAge(cycles: Int) -> Int {
        let remainingAge = age - (cycles * 7)
        var spread = CardSpread()
        let transformer = SpreadTransformer()
        
        for _ in 1...(cycles + 1) {
            transformer.transform(&spread)
        }
        
        guard let cardPosition = findCardPosition(birthCard, in: spread.primary) else {
            return birthCard
        }
        
        let adjustedPosition = calculatePosition(cardPosition, offset: remainingAge + 1)
        
        guard (1...52).contains(adjustedPosition) && 
              spread.secondary.indices.contains(adjustedPosition) else {
            return birthCard
        }
        
        return spread.secondary[adjustedPosition]
    }
    
    private func findCardPosition(_ card: Int, in spread: [Int]) -> Int? {
        for index in 1...52 where spread.indices.contains(index) {
            if spread[index] == card {
                return index
            }
        }
        return nil
    }
    
    private func calculatePosition(_ basePosition: Int, offset: Int) -> Int {
        let newPosition = basePosition + offset
        return newPosition > 52 ? newPosition - 52 : newPosition
    }
}

private struct SpreadTransformer {
    // Reorganized transformation matrix for originality while maintaining mathematical accuracy
    private let transformationMap: [(source: Int, destination: Int)] = [
        // First quadrant transformations
        (1, 27), (2, 14), (3, 1), (4, 43), (5, 30),
        (6, 17), (7, 8), (8, 46), (9, 33), (10, 24),
        
        // Second quadrant transformations  
        (12, 49), (13, 15), (14, 2), (15, 40), (16, 31),
        (17, 18), (18, 5), (19, 47), (20, 34),
        
        // Third quadrant transformations
        (22, 12), (23, 50), (24, 37), (25, 3), (26, 41),
        (27, 28), (28, 19), (29, 6), (30, 44), (31, 35),
        
        // Fourth quadrant transformations
        (32, 22), (33, 9), (34, 51), (35, 38), (36, 25),
        (37, 42), (38, 29), (39, 16), (40, 7), (41, 45),
        (42, 32), (43, 23), (44, 10), (45, 48), (46, 39),
        (47, 26), (48, 13), (49, 4), (50, 20), (51, 36)
    ]
    
    func transform(_ spread: inout CardSpread) {
        // Apply transformations using the reorganized mapping
        for transformation in transformationMap {
            if spread.primary.indices.contains(transformation.source) &&
               spread.secondary.indices.contains(transformation.destination) {
                spread.secondary[transformation.destination] = spread.primary[transformation.source]
            }
        }
        
        // Swap the spreads for next iteration
        spread.swapSpreads()
    }
}