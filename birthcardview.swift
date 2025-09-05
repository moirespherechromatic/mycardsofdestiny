import SwiftUI

struct BirthCardView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var calculator = CardCalculationService()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var detailCard: Card? = nil
    @State private var isKarmaCard = false
    @State private var karmaDescription = ""
    
    private var userCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    private var birthCard: Card {
        let components = userCalendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = BirthCardLookup.shared.calculateCardForDate(monthValue: components.month ?? 1, dayValue: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    private var karmaConnections: [KarmaConnection] {
        dataManager.getKarmaConnections(for: birthCard.id)
    }
    
    private var shareContent: ShareCardContent {
        if let detailCard = detailCard {
            return ShareCardContent.fromModal(
                card: detailCard,
                cardType: CardType.birth,
                contentType: isKarmaCard ? DetailContentType.karma(karmaDescription) : nil,
                date: dataManager.userProfile.birthDate
            )
        } else {
            return ShareCardContent.fromModal(
                card: birthCard,
                cardType: CardType.birth,
                contentType: nil,
                date: dataManager.userProfile.birthDate
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.86, green: 0.77, blue: 0.57)
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: AppConstants.Spacing.sectionSpacing) {
                    
                    mainTitleSection
                    birthCardSection
                    
                    LineBreak()
                    
                    if !karmaConnections.isEmpty {
                        karmaConnectionsSection
                    }
                    
                    LineBreak("linedesignd")
                }
                .padding(.horizontal, AppConstants.Spacing.medium)
                .padding(.vertical, AppConstants.Spacing.large)
            }
            
            if showCardDetail, let card = detailCard {
                CardDetailModalView(
                    card: card,
                    cardType: .birth,
                    contentType: isKarmaCard ? .karma(karmaDescription) : nil,
                    isPresented: $showCardDetail
                )
                .zIndex(10)
                .id("\(card.id)-\(isKarmaCard ? karmaDescription : "standard")")
            }
        }
        .standardNavigation(
            title: "Birth Card",
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
                    ShareCardShareLink(content: shareContent, size: .portrait1080x1350)
                )
            }
        )
    }
    
    private var mainTitleSection: some View {
        VStack(spacing: AppConstants.Spacing.titleSpacing) {
            SectionHeader(
                birthCard.name.uppercased(),
                fontSize: AppConstants.FontSizes.large
            )
            
            if let def = getCardDefinition(by: birthCard.id) {
                Text(def.title.lowercased())
                    .font(.custom("Iowan Old Style", size: AppConstants.FontSizes.subheadline))
                    .italic()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, AppConstants.Spacing.small)
    }
    
    private var birthCardSection: some View {
        TappableCard(
            card: birthCard,
            size: AppConstants.CardSizes.large,
            action: showBirthCard
        )
    }
    
    private var karmaConnectionsSection: some View {
        VStack(spacing: AppConstants.Spacing.large) {
            SectionHeader(
                "Life Connections",
                fontSize: AppConstants.FontSizes.title
            )
            
            if let firstConnection = karmaConnections.first {
                let cards = firstConnection.cards.compactMap { dataManager.getCard(by: $0) }
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppConstants.Spacing.large),
                        GridItem(.flexible(), spacing: AppConstants.Spacing.large)
                    ],
                    alignment: .center,
                    spacing: AppConstants.Spacing.large
                ) {
                    ForEach(cards, id: \.id) { card in
                        TappableCard(
                            card: card,
                            size: AppConstants.CardSizes.medium,
                            action: { showKarmaCard(card) }
                        )
                    }
                }
            }
        }
    }
    
    private func showBirthCard() {
        detailCard = birthCard
        isKarmaCard = false
        karmaDescription = ""
        withAnimation(.easeInOut(duration: 0.3)) {
            showCardDetail = true
        }
    }
    
    private func showKarmaCard(_ card: Card) {
        let cardId = String(card.id)
        let descRepo = DescriptionRepository.shared
        let isKarma1 = karmaConnections.first?.cards.first == card.id
        let description = isKarma1
            ? descRepo.karmaCard1Descriptions[cardId] ?? ""
            : descRepo.karmaCard2Descriptions[cardId] ?? ""

        detailCard = card
        isKarmaCard = true
        karmaDescription = description
        withAnimation(.easeInOut(duration: 0.3)) {
            showCardDetail = true
        }
    }
    
    private func dismissCardDetail() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showCardDetail = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            detailCard = nil
            isKarmaCard = false
            karmaDescription = ""
        }
    }
}

#Preview {
    NavigationView {
        BirthCardView()
    }
}
