import Foundation

class CardCalculationService: ObservableObject {
    
    // MARK: - Types
    
    private struct CardSpread {
        var sourceMatrix: [Int]
        var targetMatrix: [Int]
        
        init() {
            self.sourceMatrix = Array(0...52)
            self.targetMatrix = Array(0...52)
        }
        
        mutating func reset() {
            self.sourceMatrix = Array(0...52)
            self.targetMatrix = Array(0...52)
        }
        
        mutating func swapMatrices() {
            for index in 1...52 {
                sourceMatrix[index] = targetMatrix[index]
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
    
    func bc(month: Int, day: Int) -> Int {
        guard isValidDate(month: month, day: day) else {
            return BirthCardConstants.fallbackCard
        }
        
        return BirthCardCalculator.calculate(month: month, day: day)
    }
    
    func dc(birthDate: Date, birthCard: Int, targetDate: Date) -> DailyCardResult {
        guard isValidCard(birthCard) else {
            return createFallbackResult(for: birthCard)
        }
        
        let dateCalc = DateCalculation(from: birthDate, to: targetDate, using: systemCalendar)
        let transformedSpread = generateTransformedSpread(iterations: dateCalc.weeksDifference + 1)
        
        guard let cardIndex = findCardInSpread(birthCard, in: transformedSpread.sourceMatrix) else {
            return createFallbackResult(for: birthCard)
        }
        
        let adjustedIndex = calculateAdjustedIndex(
            baseIndex: cardIndex,
            offset: dateCalc.remainingDays
        )
        
        guard isValidIndex(adjustedIndex, in: transformedSpread.targetMatrix) else {
            return createFallbackResult(for: birthCard)
        }
        
        let resultCard = transformedSpread.targetMatrix[adjustedIndex]
        let planet = PlanetaryPeriod.from(dayNumber: dateCalc.remainingDays + 1)
        
        // Return card ID instead of Card object to avoid circular dependency
        return DailyCardResult(
            cardId: resultCard,
            planet: planet.name,
            planetNum: planet.rawValue
        )
    }
    
    func yc(birthCard: Int, age: Int) -> Int {
        guard isValidCard(birthCard), age >= 0 else {
            return BirthCardConstants.fallbackCard
        }
        
        let calculator = LongRangeCalculator(birthCard: birthCard, age: age)
        return calculator.calculate()
    }
    
    func fc(birthCard: Int, age: Int, period: Int) -> Int {
        guard isValidCard(birthCard), 
              age >= 0, 
              (1...7).contains(period) else {
            return BirthCardConstants.fallbackCard
        }
        
        let transformedSpread = generateTransformedSpread(iterations: age + 1)
        
        guard let cardIndex = findCardInSpread(birthCard, in: transformedSpread.sourceMatrix) else {
            return birthCard
        }
        
        let adjustedIndex = normalizeIndex(cardIndex + period)
        
        guard isValidIndex(adjustedIndex, in: transformedSpread.sourceMatrix) else {
            return birthCard
        }
        
        return transformedSpread.sourceMatrix[adjustedIndex]
    }
    
    func p(birthDate: Date, targetDate: Date) -> Int {
        let dateCalc = DateCalculation(from: birthDate, to: targetDate, using: systemCalendar)
        let yearDay = dateCalc.daysDifference % 365
        let period = (yearDay / 52) + 1
        return max(1, min(period, 7))
    }
    
    func chron(birthDate: Date, onDate: Date = Date()) -> Int {
        let ageComponents = systemCalendar.dateComponents([.year], from: birthDate, to: onDate)
        return max(0, ageComponents.year ?? 0)
    }
    
    // Legacy method names for compatibility
    func getBirthCard(month: Int, day: Int) -> Int {
        return bc(month: month, day: day)
    }
    
    func getDailyCard(birthDate: Date, birthCard: Int, targetDate: Date) -> DailyCardResult {
        return dc(birthDate: birthDate, birthCard: birthCard, targetDate: targetDate)
    }
    
    func getLongRangeCard(birthCard: Int, age: Int) -> Int {
        return yc(birthCard: birthCard, age: age)
    }
    
    func get52DayCard(birthCard: Int, age: Int, period: Int) -> Int {
        return fc(birthCard: birthCard, age: age, period: period)
    }
    
    func getCurrentPeriod(birthDate: Date, targetDate: Date) -> Int {
        return p(birthDate: birthDate, targetDate: targetDate)
    }
    
    func getAge(birthDate: Date, onDate: Date = Date()) -> Int {
        return chron(birthDate: birthDate, onDate: onDate)
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
        let fallbackCardId = max(1, cardId)
        return DailyCardResult(cardId: fallbackCardId, planet: "Mercury", planetNum: 1)
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
        transformer.cycle(&workingSpread)
    }
}

// MARK: - Helper Classes

private struct BirthCardConstants {
    static let baseCalculationValue = 55
    static let monthMultiplier = 2
    static let fallbackCard = 1
}

private struct BirthCardCalculator {
    static func calculate(month: Int, day: Int) -> Int {
        let rawResult = BirthCardConstants.baseCalculationValue - 
                       (day + (month << 1))
        
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
        transformer.cycle(&spread)
        
        guard let cardPosition = findCardPosition(birthCard, in: spread.targetMatrix) else {
            return birthCard
        }
        
        let adjustedPosition = calculatePosition(cardPosition, offset: age + 1)
        
        guard (1...52).contains(adjustedPosition) && 
              spread.targetMatrix.indices.contains(adjustedPosition) else {
            return birthCard
        }
        
        return spread.targetMatrix[adjustedPosition]
    }
    
    private func calculateForMatureAge(cycles: Int) -> Int {
        let remainingAge = age - (cycles * 7)
        var spread = CardSpread()
        let transformer = SpreadTransformer()
        
        for _ in 1...(cycles + 1) {
            transformer.cycle(&spread)
        }
        
        guard let cardPosition = findCardPosition(birthCard, in: spread.sourceMatrix) else {
            return birthCard
        }
        
        let adjustedPosition = calculatePosition(cardPosition, offset: remainingAge + 1)
        
        guard (1...52).contains(adjustedPosition) && 
              spread.targetMatrix.indices.contains(adjustedPosition) else {
            return birthCard
        }
        
        return spread.targetMatrix[adjustedPosition]
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
    // Data-driven transformation mapping (verified from 1893 source)
    private let transformationMap: [[Int]] = [
        [27, 1], [14, 2], [1, 3], [43, 4], [30, 5], [17, 6], [8, 7], [46, 8], [33, 9], [24, 10],
        [49, 12], [15, 13], [2, 14], [40, 15], [31, 16], [18, 17], [5, 18], [47, 19], [34, 20],
        [12, 22], [50, 23], [37, 24], [3, 25], [41, 26], [28, 27], [19, 28], [6, 29], [44, 30], [35, 31],
        [22, 32], [9, 33], [51, 34], [38, 35], [25, 36], [42, 37], [29, 38], [16, 39], [7, 40], [45, 41],
        [32, 42], [23, 43], [10, 44], [48, 45], [39, 46], [26, 47], [13, 48], [4, 49], [20, 50], [36, 51]
    ]
    
    func cycle(_ spread: inout CardSpread) {
        // Apply data-driven transformations
        for mapping in transformationMap {
            let targetIdx = mapping[0]
            let sourceIdx = mapping[1]
            
            if spread.sourceMatrix.indices.contains(sourceIdx) &&
               spread.targetMatrix.indices.contains(targetIdx) {
                spread.targetMatrix[targetIdx] = spread.sourceMatrix[sourceIdx]
            }
        }
        
        // Swap matrices for next iteration
        spread.swapMatrices()
    }
}

