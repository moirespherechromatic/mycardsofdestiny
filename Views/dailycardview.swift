import SwiftUI

struct DailyCardView: View {
    @StateObject private var viewModel = DailyCardViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var detailCard: Card? = nil
    @State private var detailContentType: GenericCardDetailView.DetailContentType? = nil
    @State private var cardDetailAnimation = false
    
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
            
            if showCardDetail, let card = detailCard, let contentType = detailContentType {
                GenericCardDetailView(
                    card: card,
                    isShowing: $showCardDetail,
                    animation: $cardDetailAnimation,
                    dismissAction: dismissCardDetail,
                    contentType: contentType
                )
            }
        }
        .standardNavigation(
            title: AppConstants.Strings.dailyInfluence,
            backAction: { presentationMode.wrappedValue.dismiss() },
            trailingContent: DataManager.shared.explorationDate != nil ? {
                AnyView(
                    Button(AppConstants.Strings.reset) {
                        DataManager.shared.explorationDate = nil
                    }
                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.callout))
                    .foregroundColor(.black)
                )
            } : nil
        )
        .errorFallback(message: viewModel.errorMessage)
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
                        contentType: .card(description: nil)
                    )
                }
            )
            
            TappablePlanetCard(
                planet: viewModel.todayCard.planet,
                size: AppConstants.CardSizes.large,
                action: {
                    showCardDetail(
                        card: viewModel.todayCard.card,
                        contentType: .planetary(planet: viewModel.todayCard.planet)
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
                        contentType: .card(description: nil)
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
                        contentType: .card(description: nil)
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
    
    private func showCardDetail(card: Card, contentType: GenericCardDetailView.DetailContentType) {
        DetailAnimationManager.showCard(
            card: card,
            contentType: contentType,
            showDetail: $showCardDetail,
            detailCard: $detailCard,
            detailContentType: $detailContentType,
            animation: $cardDetailAnimation
        )
    }
    
    private func dismissCardDetail() {
        DetailAnimationManager.dismissCard(
            showDetail: $showCardDetail,
            animation: $cardDetailAnimation,
            detailCard: $detailCard,
            detailContentType: $detailContentType
        )
    }
}

#Preview {
    NavigationView {
        DailyCardView()
    }
}