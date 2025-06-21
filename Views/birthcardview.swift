import SwiftUI

struct BirthCardView: View {
    @StateObject private var viewModel = BirthCardViewModel()
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
                    VStack(spacing: AppConstants.Spacing.titleSpacing) {
                        SectionHeader(
                            viewModel.birthCard.name.uppercased(),
                            fontSize: AppConstants.FontSizes.large
                        )
                        
                        Text(viewModel.birthCard.title.lowercased())
                            .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.headline))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppConstants.Spacing.sectionSpacing)
                    
                    TappableCard(
                        card: viewModel.birthCard,
                        size: AppConstants.CardSizes.large,
                        cornerRadius: AppConstants.CornerRadius.card,
                        action: {
                            showCardDetail(
                                card: viewModel.birthCard,
                                contentType: .card(description: nil)
                            )
                        }
                    )
                    
                    LineBreak()
                    
                    if !viewModel.karmaConnections.isEmpty {
                        karmaConnectionsSection
                    }
                    
                    LineBreak("linedesignd")
                }
                .padding(.horizontal, AppConstants.Spacing.large)
                .padding(.bottom, AppConstants.Spacing.extraLarge)
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
            title: AppConstants.Strings.birthCard,
            backAction: { presentationMode.wrappedValue.dismiss() }
        )
        .errorFallback(message: viewModel.errorMessage)
    }
    
    private var karmaConnectionsSection: some View {
        VStack(spacing: AppConstants.Spacing.large) {
            SectionHeader(
                AppConstants.Strings.karmaConnections,
                fontSize: AppConstants.FontSizes.subheadline
            )
            
            if let firstConnection = viewModel.karmaConnections.first {
                let cards = firstConnection.cards.compactMap { DataManager.shared.getCard(by: $0) }
                
                HStack(spacing: AppConstants.Spacing.extraLarge) {
                    ForEach(cards.prefix(2), id: \.id) { card in
                        TappableCard(
                            card: card,
                            size: AppConstants.CardSizes.medium,
                            cornerRadius: AppConstants.CornerRadius.card,
                            action: {
                                showCardDetail(
                                    card: card,
                                    contentType: .karma(description: firstConnection.description)
                                )
                            }
                        )
                    }
                }
            }
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
        BirthCardView()
    }
}