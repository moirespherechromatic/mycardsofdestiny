import Foundation
import Combine

class DescriptionRepository: ObservableObject {
    static let shared = DescriptionRepository()

    @Published var birthDescriptions: [String: String] = [:]
    @Published var dailyDescriptions: [String: String] = [:]
    @Published var fiftyTwoDescriptions: [String: String] = [:]
    @Published var yearlyDescriptions: [String: String] = [:]
    @Published var karmaCard1Descriptions: [String: String] = [:]
    @Published var karmaCard2Descriptions: [String: String] = [:]

    private init() {
        birthDescriptions = Self.loadJSON(named: "birth_descriptions")
        dailyDescriptions = Self.loadJSON(named: "daily_descriptions")
        fiftyTwoDescriptions = Self.loadJSON(named: "fiftytwo_descriptions")
        yearlyDescriptions = Self.loadJSON(named: "yearly_descriptions")
        karmaCard1Descriptions = Self.loadJSON(named: "karmacard1_descriptions")
        karmaCard2Descriptions = Self.loadJSON(named: "karmacard2_descriptions")
    }

    private static func loadJSON(named filename: String) -> [String: String] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Failed to find \(filename).json in bundle")
            return [:]
        }
        do {
            let data = try Data(contentsOf: url)
            let dict = try JSONDecoder().decode([String: String].self, from: data)
            return dict
        } catch {
            print("Failed to decode \(filename): \(error)")
            return [:]
        }
    }
}
