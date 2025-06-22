import SwiftUI

struct YearlySpreadView: View {
    @StateObject private var viewModel = YearlyCardViewModel()
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
                    mainCardSection
                    
                    LineBreak()
                    
                    yearlyCardsSection
                    
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
            title: AppConstants.Strings.yearlyInfluence,
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
                viewModel.currentYearCard.name.uppercased(),
                fontSize: AppConstants.FontSizes.large
            )
            
            Text(viewModel.currentYearCard.title.lowercased())
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.subheadline))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppConstants.Spacing.small)
    }
    
    private var mainCardSection: some View {
        TappableCard(
            card: viewModel.currentYearCard,
            size: AppConstants.CardSizes.large,
            action: {
                showCardDetail(
                    card: viewModel.currentYearCard,
                    contentType: .card(description: nil)
                )
            }
        )
    }
    
    private var yearlyCardsSection: some View {
        HStack(spacing: AppConstants.Spacing.cardSpacing) {
            CardWithLabel(
                card: viewModel.lastYearCard,
                label: AppConstants.Strings.lastCycle,
                size: AppConstants.CardSizes.medium,
                action: {
                    showCardDetail(
                        card: viewModel.lastYearCard,
                        contentType: .card(description: nil)
                    )
                }
            )
            
            CardWithLabel(
                card: viewModel.nextYearCard,
                label: AppConstants.Strings.nextCycle,
                size: AppConstants.CardSizes.medium,
                action: {
                    showCardDetail(
                        card: viewModel.nextYearCard,
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
        YearlySpreadView()
    }
}