import SwiftUI

struct BCard: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var viewModel = BCardViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var detailCard: Card? = nil
    @State private var cardDetailAnimation = false
    @State private var isKarmaCard = false
    @State private var karmaDescription = ""
    
    private var birthCard: Card {
        return viewModel.birthCard
    }
    
    private var karmaConnections: [KarmaConnection] {
        return viewModel.karmaConnections
    }
    
    private func dismissCardDetail() {
        withAnimation(.easeInOut(duration: 0.4)) {
            cardDetailAnimation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.4)) {
                showCardDetail = false
                isKarmaCard = false
                karmaDescription = ""
            }
        }
    }
    
    private func showBirthCard() {
        detailCard = birthCard
        isKarmaCard = false
        karmaDescription = ""
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    private func showKarmaCard(_ card: Card, description: String) {
        detailCard = card
        isKarmaCard = true
        karmaDescription = description
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppConstants.Spacing.large) {
                    
                    // Header
                    VStack(spacing: AppConstants.Spacing.medium) {
                        Text("Birth Card")
                            .font(AppTheme.Fonts.title)
                            .foregroundColor(AppTheme.Colors.primaryText)
                        
                        Text("Your core essence and life path")
                            .font(AppTheme.Fonts.subtitle)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppConstants.Spacing.large)
                    
                    // Birth Card Display
                    VStack(spacing: AppConstants.Spacing.medium) {
                        TappableCard(
                            card: birthCard,
                            onTap: showBirthCard
                        )
                        
                        Text(birthCard.title)
                            .font(AppTheme.Fonts.cardTitle)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Karma Connections
                    if !karmaConnections.isEmpty {
                        VStack(spacing: AppConstants.Spacing.medium) {
                            Text("Karma Connections")
                                .font(AppTheme.Fonts.sectionHeader)
                                .foregroundColor(AppTheme.Colors.primaryText)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppConstants.Spacing.medium) {
                                ForEach(karmaConnections.indices, id: \.self) { connectionIndex in
                                    let connection = karmaConnections[connectionIndex]
                                    ForEach(connection.cards, id: \.self) { cardId in
                                        let card = dataManager.getCard(by: cardId)
                                        TappableCard(
                                            card: card,
                                            onTap: {
                                                showKarmaCard(card, description: connection.description)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.top, AppConstants.Spacing.large)
                    }
                }
                .padding(.horizontal, AppConstants.Spacing.large)
                .padding(.bottom, AppConstants.Spacing.extraLarge)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadBirthCard()
        }
        .sheet(isPresented: $showCardDetail) {
            if let card = detailCard {
                GenericCardDetailView(
                    card: card,
                    isKarmaCard: isKarmaCard,
                    karmaDescription: karmaDescription,
                    cardDetailAnimation: $cardDetailAnimation,
                    onDismiss: dismissCardDetail
                )
            }
        }
    }
}

class BCardViewModel: ObservableObject {
    @Published var birthCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var karmaConnections: [KarmaConnection] = []
    
    private let dataManager = DataManager.shared
    
    func loadBirthCard() {
        birthCard = dataManager.getBirthCard()
        karmaConnections = dataManager.getKarmaConnections(for: birthCard.id)
    }
}

#Preview {
    BCard()
}

