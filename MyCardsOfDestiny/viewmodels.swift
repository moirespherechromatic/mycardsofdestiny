import SwiftUI
import Foundation

protocol CardViewModel: ObservableObject {
    var errorMessage: String { get set }
    var isLoading: Bool { get set }
    func handleError(_ error: Error)
    func clearError()
}

extension CardViewModel {
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
    
    func clearError() {
        errorMessage = ""
    }
}

class DailyCardViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = DataManager.shared
    
    private var userCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    var calculationDate: Date {
        let baseDate = dataManager.explorationDate ?? Date()
        return userCalendar.startOfDay(for: baseDate)
    }
    
    var birthCard: Card {
        return dataManager.getBirthCard()
    }
    
    var todayCard: DailyCardResult {
        return dataManager.getDailyCard(for: calculationDate)
    }
    
    var yesterdayCard: DailyCardResult {
        let yesterday = getDateForDayOffset(-1)
        return dataManager.getDailyCard(for: yesterday)
    }
    
    var tomorrowCard: DailyCardResult {
        let tomorrow = getDateForDayOffset(1)
        return dataManager.getDailyCard(for: tomorrow)
    }
    
    private func getDateForDayOffset(_ offset: Int) -> Date {
        return userCalendar.date(byAdding: .day, value: offset, to: calculationDate) ?? calculationDate
    }
    
    func formatCardName(_ name: String) -> String {
        return name.prefix(1).uppercased() + name.dropFirst().lowercased()
    }
}

class BirthCardViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = DataManager.shared
    
    var birthCard: Card {
        return dataManager.getBirthCard()
    }
    
    var karmaConnections: [KarmaConnection] {
        return dataManager.getKarmaConnections(for: birthCard.id)
    }
    
    func loadBirthCard() {
        // Trigger any necessary updates
        objectWillChange.send()
    }
}

class YearlyCardViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = DataManager.shared
    
    var currentYearCard: Card {
        return dataManager.getYearlyCard()
    }
    
    var currentAge: Int {
        return dataManager.getCurrentAge()
    }
    
    var lastYearCard: Card {
        guard let birthDate = dataManager.userProfile.birthDate else {
            return dataManager.getCard(by: 1)
        }
        
        let birthCard = dataManager.getBirthCard()
        let lastAge = max(0, currentAge - 1)
        let calculationService = CardCalculationService()
        let cardId = calculationService.yc(birthCard: birthCard.id, age: lastAge)
        
        return dataManager.getCard(by: cardId)
    }
    
    var nextYearCard: Card {
        guard let birthDate = dataManager.userProfile.birthDate else {
            return dataManager.getCard(by: 1)
        }
        
        let birthCard = dataManager.getBirthCard()
        let nextAge = currentAge + 1
        let calculationService = CardCalculationService()
        let cardId = calculationService.yc(birthCard: birthCard.id, age: nextAge)
        
        return dataManager.getCard(by: cardId)
    }
    
    func loadYearlyCard() {
        // Trigger any necessary updates
        objectWillChange.send()
    }
}

class FiftyTwoDayCycleViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = DataManager.shared
    
    var currentCycleCard: Card {
        return dataManager.get52DayCard()
    }
    
    var currentPeriod: Int {
        return dataManager.getCurrentPeriod()
    }
    
    var previousCycleCard: Card {
        guard let birthDate = dataManager.userProfile.birthDate else {
            return dataManager.getCard(by: 1)
        }
        
        let birthCard = dataManager.getBirthCard()
        let age = dataManager.getCurrentAge()
        let prevPeriod = max(1, currentPeriod - 1)
        let calculationService = CardCalculationService()
        let cardId = calculationService.fc(birthCard: birthCard.id, age: age, period: prevPeriod)
        
        return dataManager.getCard(by: cardId)
    }
    
    var nextCycleCard: Card {
        guard let birthDate = dataManager.userProfile.birthDate else {
            return dataManager.getCard(by: 1)
        }
        
        let birthCard = dataManager.getBirthCard()
        let age = dataManager.getCurrentAge()
        let nextPeriod = min(7, currentPeriod + 1)
        let calculationService = CardCalculationService()
        let cardId = calculationService.fc(birthCard: birthCard.id, age: age, period: nextPeriod)
        
        return dataManager.getCard(by: cardId)
    }
    
    func load52DayCard() {
        // Trigger any necessary updates
        objectWillChange.send()
    }
}

class HomeViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var pulseScale: CGFloat = 1.0
    @Published var showTapToReveal: Bool = false
    
    private let dataManager = DataManager.shared
    
    var userBirthCard: Card {
        return dataManager.getBirthCard()
    }
    
    var userYearlyCard: Card {
        return dataManager.getYearlyCard()
    }
    
    var user52DayCard: Card {
        return dataManager.get52DayCard()
    }
    
    func startHomeAnimations() {
        showTapToReveal = true
        startPulseAnimation()
    }
    
    private func startPulseAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
    
    func cardToImageName(_ card: Card) -> String {
        let suitPrefix: String
        switch card.suit {
        case .hearts:
            suitPrefix = "h"
        case .clubs:
            suitPrefix = "c"
        case .diamonds:
            suitPrefix = "d"
        case .spades:
            suitPrefix = "s"
        }
        
        let valueString: String
        switch card.value.lowercased() {
        case "a":
            valueString = "01"
        case "j":
            valueString = "11"
        case "q":
            valueString = "12"
        case "k":
            valueString = "13"
        default:
            if let intValue = Int(card.value) {
                valueString = String(format: "%02d", intValue)
            } else {
                valueString = "01"
            }
        }
        
        return "\(suitPrefix)\(valueString)"
    }
}

