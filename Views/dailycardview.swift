import SwiftUI

struct DailyCardView: View {
    @StateObject private var viewModel = DailyCardViewModel()
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var selectedCard: Card? = nil
    @State private var selectedCardType: CardType = .daily
    @State private var selectedContentType: DetailContentType? = nil
    
    private var shareContent: ShareCardContent {
        if let selectedCard = selectedCard {
            return ShareCardContent.fromModal(
                card: selectedCard,
                cardType: selectedCardType,
                contentType: selectedContentType,
                date: viewModel.calculationDate
            )
        } else {
            return ShareCardContent.fromModal(
                card: viewModel.todayCard.card,
                cardType: CardType.daily,
                contentType: nil,
                date: viewModel.calculationDate
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.86, green: 0.77, blue: 0.57)
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: AppConstants.Spacing.sectionSpacing) {
                    if DataManager.shared.explorationDate != nil {
                        dateExplorationIndicator
                    }
                    
                    mainTitleSection
                    todayCardSection
                    
                    LineBreak()
                    
                    lastCycleCardsSection
                    
                    LineBreak("linedesignd")
                }
                .padding(.horizontal, AppConstants.Spacing.medium)
                .padding(.vertical, AppConstants.Spacing.large)
            }
            
            if showCardDetail, let card = selectedCard {
                CardDetailModalView(
                    card: card,
                    cardType: selectedCardType,
                    contentType: selectedContentType,
                    isPresented: $showCardDetail
                )
                .zIndex(10)
                .id("\(card.id)-\(String(describing: selectedContentType))")
            }
        }
        .standardNavigation(
            title: AppConstants.Strings.dailyInfluence,
            backAction: {
                if showCardDetail {
                    withAnimation(.spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping)) {
                        showCardDetail = false
                    }
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            },
            trailingContent: {
                AnyView(
                    HStack(spacing: 12) {
                        ShareCardShareLink(content: shareContent, size: .portrait1080x1350)
                        
                        if DataManager.shared.explorationDate != nil {
                            Button(AppConstants.Strings.reset) {
                                DataManager.shared.explorationDate = nil
                            }
                            .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.callout))
                            .foregroundColor(.black)
                        }
                    }
                )
            }
        )
        .errorFallback(message: viewModel.errorMessage)
        .onAppear {
            dataManager.markDailyCardAsRevealed()
        }
        .onDisappear {
            dataManager.markDailyCardAsRevealed()
        }
    }
    
    private var mainTitleSection: some View {
        VStack(spacing: AppConstants.Spacing.titleSpacing) {
            SectionHeader(
                viewModel.formatCardName(viewModel.todayCard.card.name).uppercased(),
                fontSize: AppConstants.FontSizes.large
            )
            
            Text("as your \(viewModel.todayCard.planet) day")
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.subheadline))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppConstants.Spacing.small)
    }
    
    private var todayCardSection: some View {
        HStack(spacing: AppConstants.Spacing.cardSpacing) {
            TappableCard(
                card: viewModel.todayCard.card,
                size: AppConstants.CardSizes.large,
                action: {
                    showCardDetail(
                        card: viewModel.todayCard.card,
                        cardType: .daily,
                        contentType: .standard
                    )
                }
            )
            
            TappablePlanetCard(
                planet: viewModel.todayCard.planet,
                size: AppConstants.CardSizes.large,
                action: {
                    showCardDetail(
                        card: viewModel.todayCard.card,
                        cardType: .daily,
                        contentType: .planetary(viewModel.todayCard.planet)
                    )
                }
            )
        }
    }
    
    private var lastCycleCardsSection: some View {
        HStack(spacing: AppConstants.Spacing.cardSpacing) {
            CardWithLabel(
                card: viewModel.yesterdayCard.card,
                label: AppConstants.Strings.lastCycle,
                size: AppConstants.CardSizes.medium,
                action: {
                    showCardDetail(
                        card: viewModel.yesterdayCard.card,
                        cardType: .daily,
                        contentType: .standard
                    )
                }
            )
            
            CardWithLabel(
                card: viewModel.tomorrowCard.card,
                label: AppConstants.Strings.nextCycle,
                size: AppConstants.CardSizes.medium,
                action: {
                    showCardDetail(
                        card: viewModel.tomorrowCard.card,
                        cardType: .daily,
                        contentType: .standard
                    )
                }
            )
        }
    }
    
    private var dateExplorationIndicator: some View {
        VStack(spacing: 4) {
            Text(AppConstants.Strings.exploring)
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.callout))
                .foregroundColor(.black)
            
            Text(viewModel.calculationDate, style: .date)
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
                .fontWeight(.heavy)
                .foregroundColor(.black)
        }
        .padding(.horizontal, AppConstants.Spacing.medium)
        .padding(.vertical, AppConstants.Spacing.small)
        .background(Color.black.opacity(0.05))
        .cornerRadius(AppConstants.CornerRadius.small)
    }
    
    private func showCardDetail(card: Card, cardType: CardType, contentType: DetailContentType?) {
        selectedCard = card
        selectedCardType = cardType
        selectedContentType = contentType
        withAnimation(.easeInOut(duration: 0.3)) {
            showCardDetail = true
        }
    }
    
    private func dismissCardDetail() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showCardDetail = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedCard = nil
            selectedCardType = .daily
            selectedContentType = nil
        }
    }
}

#Preview {
    NavigationView {
        DailyCardView()
    }
}
