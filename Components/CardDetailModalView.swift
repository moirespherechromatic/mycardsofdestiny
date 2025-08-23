//
//  CardDetailModalView.swift
//  MyCardsOfDestiny
//
//  Created by futura on 7/10/25.
//

import SwiftUI

enum CardType {
    case planetary, daily, birth, yearly, fiftyTwoDay
}

enum DetailContentType {
    case standard, extended, karma(String), planetary(String)
}

struct CardDetailModalView: View {
    let card: Card
    let cardType: CardType
    let contentType: DetailContentType?
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Always render background, control visibility with opacity - covers EVERYTHING including status bar and nav bar
            Color.black.opacity(isPresented ? 0.6 : 0)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    closeModal()
                }
                .allowsHitTesting(isPresented)
            
            // The modal content - always rendered, controlled by opacity/scale
            ScrollView {
                VStack(spacing: 25) {
                    // Card image - handle planetary vs regular cards
                    Group {
                        if case .planetary(let planet) = contentType {
                            if let planetImage = ImageManager.shared.loadPlanetImage(for: planet) {
                                Image(uiImage: planetImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        } else {
                            if let uiImage = ImageManager.shared.loadCardImage(for: card) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    .id("cardTop")
                    
                    VStack(spacing: 15) {
                        // Title section - handle planetary vs regular cards
                        Group {
                            if case .planetary(let planet) = contentType {
                                let planetInfo = AppConstants.PlanetDescriptions.getDescription(for: planet)
                                Text(planetInfo.title.lowercased())
                                    .font(.custom("Apothicaire Light Cd", size: 22))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            } else {
                                if let def = getCardDefinition(by: card.id) {
                                    Text(def.name.uppercased())
                                        .font(.custom("Apothicaire Light Cd", size: 28))
                                        .fontWeight(.heavy)
                                        .foregroundColor(.black)
                                    
                                    Text(def.title.lowercased())
                                        .font(.custom("Apothicaire Light Cd", size: 22))
                                        .fontWeight(.heavy)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        
                        Rectangle()
                            .frame(width: 80, height: 1)
                            .foregroundColor(.black.opacity(0.6))
                        
                        // Card description text (passed from view files)
                        Text(descriptionText())
                            .font(.custom("Apothicaire Light Cd", size: 18))
                            .foregroundColor(.black)
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 25)
                    }
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollPosition(id: .constant("cardTop"))
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0.86, green: 0.77, blue: 0.57).opacity(0.95))
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .scaleEffect(isPresented ? 1 : 0.8)
            .opacity(isPresented ? 1 : 0)
            .padding(.horizontal, 25)
            .padding(.top, 44)
            .padding(.bottom, 20)
            .allowsHitTesting(isPresented)
            .zIndex(10)
        }
        .animation(.spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping), value: isPresented)
    }
    
    private func closeModal() {
        withAnimation(.spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping)) {
            isPresented = false
        }
    }
    
    private func descriptionText() -> String {
        switch contentType {
        case .karma(let description):
            return description
        case .planetary(let planet):
            let planetInfo = AppConstants.PlanetDescriptions.getDescription(for: planet)
            return planetInfo.description
        case .extended:
            return "Extended content handled by view"
        case .standard, .none:
            let repo = DescriptionRepository.shared
            let cardID = String(card.id)
            switch cardType {
            case .daily:
                return repo.dailyDescriptions[cardID] ?? "No daily description available."
            case .birth:
                return repo.birthDescriptions[cardID] ?? "No birth description available."
            case .yearly:
                return repo.yearlyDescriptions[cardID] ?? "No yearly description available."
            case .fiftyTwoDay:
                return repo.fiftyTwoDescriptions[cardID] ?? "No 52-day description available."
            case .planetary:
                return "Error: Planetary descriptions should be passed via contentType"
            }
        }
    }
}
