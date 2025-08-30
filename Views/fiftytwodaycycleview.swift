import SwiftUI

struct FiftyTwoDayCycleView: View {
    @StateObject private var viewModel = FiftyTwoDayCycleViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var selectedCard: Card? = nil
    @State private var selectedCardType: CardType? = nil
    @State private var selectedContentType: DetailContentType? = nil

    private var shareContent: ShareCardContent {
        if let selectedCard = selectedCard, let selectedCardType = selectedCardType {
            return ShareCardContent.fromModal(
                card: selectedCard,
                cardType: selectedCardType,
                contentType: selectedContentType,
                date: Date()
            )
        } else {
            return ShareCardContent.fromModal(
                card: viewModel.currentPeriodCard,
                cardType: CardType.fiftyTwoDay,
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
                    mainCardsSection

                    LineBreak()

                    periodCardsSection

                    LineBreak("linedesignd")
                }
                .padding(.horizontal, AppConstants.Spacing.medium)
                .padding(.vertical, AppConstants.Spacing.large)
            }

            if showCardDetail, let card = selectedCard, let cardType = selectedCardType {
                CardDetailModalView(
                    card: card,
                    cardType: cardType,
                    contentType: selectedContentType,
                    isPresented: $showCardDetail
                )
                .zIndex(10)
                .id("\(card.id)-\(String(describing: selectedContentType))")
            }
        }
        .standardNavigation(
            title: AppConstants.Strings.fiftyTwoDayInfluence,
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
                        cardType: .fiftyTwoDay,
                        contentType: .standard
                    )
                }
            )

            TappablePlanetCard(
                planet: viewModel.planetaryPeriod,
                size: AppConstants.CardSizes.large,
                action: {
                    showCardDetail(
                        card: viewModel.currentPeriodCard,
                        cardType: .fiftyTwoDay,
                        contentType: .planetary(viewModel.planetaryPeriod)
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
                        cardType: .fiftyTwoDay,
                        contentType: .standard
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
                        cardType: .fiftyTwoDay,
                        contentType: .standard
                    )
                }
            )
        }
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
            selectedCardType = nil
            selectedContentType = nil
        }
    }
}

#Preview {
    NavigationView {
        FiftyTwoDayCycleView()
    }
}
