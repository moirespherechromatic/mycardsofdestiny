import SwiftUI

struct YearlySpreadView: View {
    @StateObject private var viewModel = YearlyCardViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var selectedCard: Card? = nil
    
    private let cardType: CardType = .yearly
    
    private var shareContent: ShareCardContent {
        if let selectedCard = selectedCard {
            return ShareCardContent.fromModal(
                card: selectedCard,
                cardType: cardType,
                contentType: nil,
                date: Date()
            )
        } else {
            return ShareCardContent.fromModal(
                card: viewModel.currentYearCard,
                cardType: CardType.yearly,
                contentType: nil,
                date: Date()
            )
        }
    }
    
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
            
            if showCardDetail, let card = selectedCard {
                CardDetailModalView(
                    card: card,
                    cardType: cardType,
                    contentType: nil,
                    isPresented: $showCardDetail
                )
                .zIndex(10)
                .id("\(card.id)")
            }
        }
        .standardNavigation(
            title: AppConstants.Strings.yearlyInfluence,
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
    }
    
    private var headerSection: some View {
        VStack(spacing: AppConstants.Spacing.titleSpacing) {
            SectionHeader(
                viewModel.currentYearCard.name.uppercased(),
                fontSize: AppConstants.FontSizes.large
            )
            if let def = getCardDefinition(by: viewModel.currentYearCard.id) {
                Text(def.title.lowercased())
                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.subheadline))
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, AppConstants.Spacing.small)
    }
    
    private var mainCardSection: some View {
        TappableCard(
            card: viewModel.currentYearCard,
            size: AppConstants.CardSizes.large,
            action: {
                showCardDetail(card: viewModel.currentYearCard)
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
                    showCardDetail(card: viewModel.lastYearCard)
                }
            )
            
            CardWithLabel(
                card: viewModel.nextYearCard,
                label: AppConstants.Strings.nextCycle,
                size: AppConstants.CardSizes.medium,
                action: {
                    showCardDetail(card: viewModel.nextYearCard)
                }
            )
        }
    }
    
    private func showCardDetail(card: Card) {
        selectedCard = card
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
        }
    }
}

#Preview {
    NavigationView {
        YearlySpreadView()
    }
}
