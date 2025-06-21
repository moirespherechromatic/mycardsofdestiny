import SwiftUI

struct FiftyTwoDayCycleView: View {
    @StateObject private var viewModel = FiftyTwoDayCycleViewModel()
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
                    headerSection
                    mainCardsSection
                    
                    LineBreak()
                    
                    periodCardsSection
                    
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
            title: AppConstants.Strings.fiftyTwoDayInfluence,
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
    
    private var headerSection: some View {
        VStack(spacing: AppConstants.Spacing.titleSpacing) {
            SectionHeader(
                viewModel.currentPeriodCard.name.uppercased(),
                fontSize: AppConstants.FontSizes.large
            )
            
            Text("in your \(viewModel.planetaryPeriod) phase")
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.subheadline))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppConstants.Spacing.small)
    }
    
    private var mainCardsSection: some View {
        HStack(spacing: AppConstants.Spacing.cardSpacing) {
            TappableCard(
                card: viewModel.currentPeriodCard,
                size: AppConstants.CardSizes.large,
                action: {
                    showCardDetail(
                        card: viewModel.currentPeriodCard,
                        contentType: .card(description: nil)
                    )
                }
            )
            
            TappablePlanetCard(
                planet: viewModel.planetaryPeriod,
                size: AppConstants.CardSizes.large,
                action: {
                    showCardDetail(
                        card: viewModel.currentPeriodCard,
                        contentType: .planetary(planet: viewModel.planetaryPeriod)
                    )
                }
            )
        }
    }
    
    private var periodCardsSection: some View {
        HStack(spacing: AppConstants.Spacing.cardSpacing) {
            CardWithLabel(
                card: viewModel.lastPeriodCard,
                label: AppConstants.Strings.lastCycle,
                size: AppConstants.CardSizes.medium,
                action: {
                    showCardDetail(
                        card: viewModel.lastPeriodCard,
                        contentType: .card(description: nil)
                    )
                }
            )
            
            CardWithLabel(
                card: viewModel.nextPeriodCard,
                label: AppConstants.Strings.nextCycle,
                size: AppConstants.CardSizes.medium,
                action: {
                    showCardDetail(
                        card: viewModel.nextPeriodCard,
                        contentType: .card(description: nil)
                    )
                }
            )
        }
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
        FiftyTwoDayCycleView()
    }
}