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
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text((birthCard.name.uppercased()))
                            .font(.custom("Apothicaire Light Cd", size: 28))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)

                        if let def = getCardDefinition(by: birthCard.id) {
                            Text(def.title.lowercased())
                                .font(.custom("Apothicaire Light Cd", size: 22))
                                .italic()
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        
                    }
                    .padding(.top, 20)
                    
                    Button(action: showBirthCard) {
                        if let uiImage = ImageManager.shared.loadCardImage(for: birthCard) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 156, height: 229)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        } else {
                            CardImageView(card: birthCard)
                                .frame(width: 156, height: 229)
                        }
                    }
                    
                    if let linebreakImage = UIImage(named: "linedesign") {
                        Image(uiImage: linebreakImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                    }
                    
                    if !karmaConnections.isEmpty {
                        karmaConnectionsSection
                    }
                    
                    if let linebreakImage = UIImage(named: "linedesignd") {
                        Image(uiImage: linebreakImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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
        .background(Color(red: 0.86, green: 0.77, blue: 0.57))
        .environment(\.font, .custom("Apothicaire Light Cd", size: 16))
        .navigationTitle("Birth Card")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if showCardDetail {
                        withAnimation(.spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping)) {
                            showCardDetail = false
                        }
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Back")
            }
            ToolbarItem(placement: .principal) {
                Text("Birth Card")
                    .font(.custom("Apothicaire Light Cd", size: 24))
                    .foregroundColor(.black)
                    .fontWeight(.heavy)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareCardShareLink(content: shareContent, size: .portrait1080x1350)
            }
        }
    }
    
    private var karmaConnectionsSection: some View {
        VStack(spacing: 24) {
            Text("Karmic Connections")
                .font(.custom("Apothicaire Light Cd", size: 20))
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            if let firstConnection = karmaConnections.first {
                let cards = firstConnection.cards.compactMap { dataManager.getCard(by: $0) }
                
                HStack(spacing: 40) {
                    ForEach(cards.prefix(2), id: \.id) { card in
                        Button(action: {
                            showKarmaCard(card)
                        }) {
                            if let uiImage = ImageManager.shared.loadCardImage(for: card) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 176)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                            } else {
                                CardImageView(card: card)
                                    .frame(width: 120, height: 176)
                            }
                        }
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

struct CardImageView: View {
    let card: Card
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.black, lineWidth: 2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.95, green: 0.88, blue: 0.72))
            )
            .overlay(
                VStack {
                    if card.suit == .hearts {
                        Image(systemName: "heart")
                            .font(.title2)
                            .foregroundColor(.red)
                    } else if card.suit == .clubs {
                        Image(systemName: "suit.club")
                            .font(.title2)
                            .foregroundColor(.black)
                    } else if card.suit == .diamonds {
                        Image(systemName: "diamond")
                            .font(.title2)
                            .foregroundColor(.red)
                    } else if card.suit == .spades {
                        Image(systemName: "suit.spade")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    if card.suit == .hearts {
                        Image(systemName: "heart")
                            .font(.title2)
                            .foregroundColor(.red)
                            .rotationEffect(.degrees(180))
                    } else if card.suit == .clubs {
                        Image(systemName: "suit.club")
                            .font(.title2)
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(180))
                    } else if card.suit == .diamonds {
                        Image(systemName: "diamond")
                            .font(.title2)
                            .foregroundColor(.red)
                            .rotationEffect(.degrees(180))
                    } else if card.suit == .spades {
                        Image(systemName: "suit.spade")
                            .font(.title2)
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(8)
            )
    }
}

#Preview {
    NavigationView {
        BirthCardView()
    }
}
