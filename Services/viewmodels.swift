import SwiftUI
import Foundation

// MARK: - Base ViewModel Protocol
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

// MARK: - Daily Card ViewModel
class DailyCardViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = DataManager.shared
    private let calculator = CardCalculationService()
    
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
        let components = userCalendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    var todayCard: DailyCardResult {
        calculator.getDailyCard(
            birthDate: dataManager.userProfile.birthDate,
            birthCard: birthCard.id,
            targetDate: calculationDate
        )
    }
    
    var yesterdayCard: DailyCardResult {
        let yesterday = getDateForDayOffset(-1)
        return calculator.getDailyCard(
            birthDate: dataManager.userProfile.birthDate,
            birthCard: birthCard.id,
            targetDate: yesterday
        )
    }
    
    var tomorrowCard: DailyCardResult {
        let tomorrow = getDateForDayOffset(1)
        return calculator.getDailyCard(
            birthDate: dataManager.userProfile.birthDate,
            birthCard: birthCard.id,
            targetDate: tomorrow
        )
    }
    
    private func getDateForDayOffset(_ offset: Int) -> Date {
        return userCalendar.date(byAdding: .day, value: offset, to: calculationDate) ?? calculationDate
    }
    
    func formatCardName(_ name: String) -> String {
        return name.prefix(1).uppercased() + name.dropFirst().lowercased()
    }
}

// MARK: - Birth Card ViewModel
class BirthCardViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = DataManager.shared
    private let calculator = CardCalculationService()
    
    private var userCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    var birthCard: Card {
        let components = userCalendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    var karmaConnections: [KarmaConnection] {
        dataManager.getKarmaConnections(for: birthCard.id)
    }
}

// MARK: - Yearly Card ViewModel
class YearlyCardViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = DataManager.shared
    private let calculator = CardCalculationService()
    
    var calculationDate: Date {
        dataManager.explorationDate ?? Date()
    }
    
    var birthCard: Card {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    var currentYearCard: Card {
        getYearlyCard(for: .current)
    }
    
    var lastYearCard: Card {
        getYearlyCard(for: .last)
    }
    
    var nextYearCard: Card {
        getYearlyCard(for: .next)
    }
    
    enum YearPeriod {
        case last, current, next
    }
    
    func getYearlyCard(for period: YearPeriod) -> Card {
        let age = calculator.getAge(birthDate: dataManager.userProfile.birthDate, onDate: calculationDate)
        let adjustedAge: Int
        
        switch period {
        case .last: adjustedAge = age - 1
        case .current: adjustedAge = age
        case .next: adjustedAge = age + 1
        }
        
        let cardId = calculator.getLongRangeCard(birthCard: birthCard.id, age: adjustedAge)
        return dataManager.getCard(by: cardId)
    }
}

// MARK: - 52-Day Cycle ViewModel
class FiftyTwoDayCycleViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = DataManager.shared
    private let calculator = CardCalculationService()
    
    var calculationDate: Date {
        dataManager.explorationDate ?? Date()
    }
    
    var birthCard: Card {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    var currentPeriodNumber: Int {
        calculator.getCurrentPeriod(birthDate: dataManager.userProfile.birthDate, targetDate: calculationDate)
    }
    
    var currentPeriodCard: Card {
        getPeriodCard(for: .current)
    }
    
    var lastPeriodCard: Card {
        getPeriodCard(for: .last)
    }
    
    var nextPeriodCard: Card {
        getPeriodCard(for: .next)
    }
    
    var planetaryPeriod: String {
        let planets = ["Error", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
        return planets.indices.contains(currentPeriodNumber) ? planets[currentPeriodNumber] : "Unknown"
    }
    
    enum CyclePeriod {
        case last, current, next
    }
    
    func getPeriodCard(for period: CyclePeriod) -> Card {
        let age = calculator.getAge(birthDate: dataManager.userProfile.birthDate, onDate: calculationDate)
        let periodNumber: Int
        
        switch period {
        case .last: periodNumber = currentPeriodNumber == 1 ? 7 : currentPeriodNumber - 1
        case .current: periodNumber = currentPeriodNumber
        case .next: periodNumber = currentPeriodNumber == 7 ? 1 : currentPeriodNumber + 1
        }
        
        let cardId = calculator.get52DayCard(birthCard: birthCard.id, age: age, period: periodNumber)
        return dataManager.getCard(by: cardId)
    }
}

// MARK: - Home ViewModel
class HomeViewModel: CardViewModel {
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showTapToReveal = false
    @Published var pulseScale: CGFloat = 1.0
    
    private let dataManager = DataManager.shared
    private let calculator = CardCalculationService()
    
    var userBirthCard: Card {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    var userYearlyCard: Card {
        let age = calculator.getAge(birthDate: dataManager.userProfile.birthDate, onDate: Date())
        let cardId = calculator.getLongRangeCard(birthCard: userBirthCard.id, age: age)
        return dataManager.getCard(by: cardId)
    }
    
    var user52DayCard: Card {
        let age = calculator.getAge(birthDate: dataManager.userProfile.birthDate, onDate: Date())
        let currentPeriod = calculator.getCurrentPeriod(birthDate: dataManager.userProfile.birthDate, targetDate: Date())
        let cardId = calculator.get52DayCard(birthCard: userBirthCard.id, age: age, period: currentPeriod)
        return dataManager.getCard(by: cardId)
    }
    
    func startHomeAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: AppConstants.Animation.fadeInDuration)) {
                self.showTapToReveal = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: AppConstants.Animation.pulseDuration)) {
                    self.pulseScale = AppConstants.Animation.pulseScale
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Animation.pulseDuration) {
                    withAnimation(.easeInOut(duration: AppConstants.Animation.pulseDuration)) {
                        self.pulseScale = 1.0
                    }
                }
            }
        }
    }
    
    func cardToImageName(_ card: Card) -> String {
        let value = String(describing: card.value).lowercased()
        let suit = String(describing: card.suit).lowercased()
        
        let suitChar: String
        switch suit {
        case "hearts": suitChar = "h"
        case "diamonds": suitChar = "d"
        case "clubs": suitChar = "c"
        case "spades": suitChar = "s"
        default: suitChar = "s"
        }
        
        let valueChar: String
        switch value {
        case "ace": valueChar = "a"
        case "jack": valueChar = "j"
        case "queen": valueChar = "q"
        case "king": valueChar = "k"
        case "two": valueChar = "2"
        case "three": valueChar = "3"
        case "four": valueChar = "4"
        case "five": valueChar = "5"
        case "six": valueChar = "6"
        case "seven": valueChar = "7"
        case "eight": valueChar = "8"
        case "nine": valueChar = "9"
        case "ten": valueChar = "10"
        default: valueChar = value
        }
        
        return "\(valueChar)\(suitChar)"
    }
}