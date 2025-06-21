import UIKit
import Foundation // if you have this already

// rest of your code

import Foundation

class CardCalculationService: ObservableObject {
    private var spread1 = Array(0...52)
    private var spread2 = Array(0...52)
    
    // MARK: - Setup and Quadrate Functions
    private func setupSpreads() {
        spread1 = Array(0...52)
        spread2 = Array(0...52)
    }
    
    private func quadrate() {
        // Bounds checking to prevent crashes
        guard spread1.count > 52 && spread2.count > 52 else {
            print("ERROR: Spread arrays not properly initialized")
            return
        }
        
        spread2[27] = spread1[1]
        spread2[14] = spread1[2]
        spread2[1] = spread1[3]
        spread2[43] = spread1[4]
        spread2[30] = spread1[5]
        spread2[17] = spread1[6]
        spread2[8] = spread1[7]
        spread2[46] = spread1[8]
        spread2[33] = spread1[9]
        spread2[24] = spread1[10]
        spread2[49] = spread1[12]
        spread2[15] = spread1[13]
        spread2[2] = spread1[14]
        spread2[40] = spread1[15]
        spread2[31] = spread1[16]
        spread2[18] = spread1[17]
        spread2[5] = spread1[18]
        spread2[47] = spread1[19]
        spread2[34] = spread1[20]
        spread2[12] = spread1[22]
        spread2[50] = spread1[23]
        spread2[37] = spread1[24]
        spread2[3] = spread1[25]
        spread2[41] = spread1[26]
        spread2[28] = spread1[27]
        spread2[19] = spread1[28]
        spread2[6] = spread1[29]
        spread2[44] = spread1[30]
        spread2[35] = spread1[31]
        spread2[22] = spread1[32]
        spread2[9] = spread1[33]
        spread2[51] = spread1[34]
        spread2[38] = spread1[35]
        spread2[25] = spread1[36]
        spread2[42] = spread1[37]
        spread2[29] = spread1[38]
        spread2[16] = spread1[39]
        spread2[7] = spread1[40]
        spread2[45] = spread1[41]
        spread2[32] = spread1[42]
        spread2[23] = spread1[43]
        spread2[10] = spread1[44]
        spread2[48] = spread1[45]
        spread2[39] = spread1[46]
        spread2[26] = spread1[47]
        spread2[13] = spread1[48]
        spread2[4] = spread1[49]
        spread2[20] = spread1[50]
        spread2[36] = spread1[51]
        
        for c in 1...52 {
            spread1[c] = spread2[c]
        }
    }
    
    // MARK: - Core Calculations
    func getBirthCard(month: Int, day: Int) -> Int {
        // Validate input
        guard month >= 1 && month <= 12 && day >= 1 && day <= 31 else {
            print("ERROR: Invalid birth date - month: \(month), day: \(day)")
            return 1 // Default to Ace of Hearts
        }
        
        let result = 55 - ((month * 2) + day)
        
        // Ensure result is within valid range
        if result < 1 || result > 52 {
            print("ERROR: Birth card calculation out of range: \(result)")
            return 1
        }
        
        return result
    }
    
    func getDailyCard(birthDate: Date, birthCard: Int, targetDate: Date) -> DailyCardResult {
        // Validate inputs
        guard birthCard >= 1 && birthCard <= 52 else {
            print("ERROR: Invalid birth card ID: \(birthCard)")
            let fallbackCard = DataManager.shared.getCard(by: 1)
            return DailyCardResult(card: fallbackCard, planet: "Mercury", planetNum: 1)
        }
        
        setupSpreads()
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: birthDate, to: targetDate).day ?? 0
        let weeks = days / 7
        let daysRemaining = days % 7
        
        for _ in 1...(weeks + 1) {
            quadrate()
        }
        
        var i = 1
        while i <= 52 && spread1[i] != birthCard {
            i += 1
        }
        
        i = i + 1
        if (i + daysRemaining) > 52 {
            i = i - 52
        }
        
        // Bounds check
        let cardIndex = i + daysRemaining
        guard cardIndex >= 1 && cardIndex <= 52 && spread2.count > cardIndex else {
            print("ERROR: Daily card calculation out of bounds")
            let fallbackCard = DataManager.shared.getCard(by: birthCard)
            return DailyCardResult(card: fallbackCard, planet: "Mercury", planetNum: 1)
        }
        
        let planetaryPeriod = getPlanetaryPeriod(daysRemaining + 1)
        let cardId = spread2[cardIndex]
        let card = DataManager.shared.getCard(by: cardId)
        
        return DailyCardResult(
            card: card,
            planet: planetaryPeriod,
            planetNum: daysRemaining + 1
        )
    }
    
    func getLongRangeCard(birthCard: Int, age: Int) -> Int {
        // Validate inputs
        guard birthCard >= 1 && birthCard <= 52 && age >= 0 else {
            print("ERROR: Invalid inputs - birthCard: \(birthCard), age: \(age)")
            return 1
        }
        
        setupSpreads()
        
        let lrAge = age / 7
        
        if lrAge < 1 {
            quadrate()
            var i = 1
            while i <= 52 && spread2[i] != birthCard {
                i += 1
            }
            
            if i + age + 1 > 52 {
                i = i - 52
            }
            
            let resultIndex = i + age + 1
            guard resultIndex >= 1 && resultIndex <= 52 && spread2.count > resultIndex else {
                print("ERROR: Long range card calculation out of bounds")
                return birthCard
            }
            
            return spread2[resultIndex]
        } else {
            let quads = lrAge
            let quadAge = age - (quads * 7)
            
            for _ in 1...(quads + 1) {
                quadrate()
            }
            
            var i = 1
            while i <= 52 && spread1[i] != birthCard {
                i += 1
                if i > 52 { break }
            }
            
            if (i + quadAge + 1) > 52 {
                i = i - 52
            }
            
            let resultIndex = i + quadAge + 1
            guard resultIndex >= 1 && resultIndex <= 52 && spread2.count > resultIndex else {
                print("ERROR: Long range card calculation out of bounds")
                return birthCard
            }
            
            return spread2[resultIndex]
        }
    }
    
    func get52DayCard(birthCard: Int, age: Int, period: Int) -> Int {
        // Validate inputs
        guard birthCard >= 1 && birthCard <= 52 && age >= 0 && period >= 1 && period <= 7 else {
            print("ERROR: Invalid inputs - birthCard: \(birthCard), age: \(age), period: \(period)")
            return 1
        }
        
        setupSpreads()
        
        for _ in 1...(age + 1) {
            quadrate()
        }
        
        var i = 1
        while i <= 52 && spread1[i] != birthCard {
            i += 1
        }
        
        var temp = i + period
        if temp > 52 {
            temp = temp - 52
        }
        
        guard temp >= 1 && temp <= 52 && spread1.count > temp else {
            print("ERROR: 52-day card calculation out of bounds")
            return birthCard
        }
        
        return spread1[temp]
    }
    
    func getCurrentPeriod(birthDate: Date, targetDate: Date) -> Int {
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: birthDate, to: targetDate).day ?? 0
        
        // Match JavaScript logic exactly: dayInYear % 365, then divide by 52
        let dayInYear = totalDays % 365
        let currentPeriod = (dayInYear / 52) + 1
        
        // Ensure period is between 1-7 (JavaScript ensures this with Math.min/max)
        let clampedPeriod = max(1, min(currentPeriod, 7))
        
        return clampedPeriod
    }
    
    func getAge(birthDate: Date, onDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: onDate)
        return ageComponents.year ?? 0
    }
    
    private func getPlanetaryPeriod(_ day: Int) -> String {
        let planets = ["Error", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
        return planets.indices.contains(day) ? planets[day] : "Unknown"
    }
}
