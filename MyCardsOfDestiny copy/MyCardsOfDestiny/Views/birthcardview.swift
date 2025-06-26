import SwiftUI

struct BirthCardView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var viewModel = BirthCardViewModel()
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
                        
                        Text(birthCard.title.lowercased())
                            .font(.custom("Apothicaire Light Cd", size: 22))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
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
                ZStack {
                    Color.black.opacity(cardDetailAnimation ? 0.5 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissCardDetail()
                        }
                    
                    BirthCardDetailView(
                        card: card,
                        isShowing: $showCardDetail,
                        animation: $cardDetailAnimation,
                        dismissAction: dismissCardDetail,
                        isKarmaCard: isKarmaCard,
                        karmaDescription: karmaDescription
                    )
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .background(Color(red: 0.86, green: 0.77, blue: 0.57))
        .environment(\.font, .custom("Apothicaire Light Cd", size: 16))
        .navigationTitle("Birth Card")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Birth Card")
                    .font(.custom("Apothicaire Light Cd", size: 24))
                    .foregroundColor(.black)
                    .fontWeight(.heavy)
            }
        }
        .errorFallback(message: viewModel.errorMessage)
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
                            showKarmaCard(card, description: firstConnection.description)
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
}

// MARK: - Supporting ViewModel

class BirthCardViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    
    private let dataManager = DataManager.shared
    private let calculator = CardCalculationService()
    
    private var userCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    var birthCard: Card {
        let components = userCalendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    var karmaConnections: [KarmaConnection] {
        return dataManager.getKarmaConnections(for: birthCard.id)
    }
}

// MARK: - Supporting Views (unchanged)

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

struct BirthCardDetailView: View {
    let card: Card
    @Binding var isShowing: Bool
    @Binding var animation: Bool
    var dismissAction: () -> Void
    var isKarmaCard: Bool = false
    var karmaDescription: String = ""
    
    var body: some View {
        ZStack {
            ScrollView {
                HStack {
                    Spacer()
                    VStack(spacing: 25) {
                    if let uiImage = ImageManager.shared.loadCardImage(for: card) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: animation ? 300 : 150)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    if animation {
                        VStack(spacing: 15) {
                            Text(card.name.uppercased())
                                .font(.custom("Apothicaire Light Cd", size: 32))
                                .fontWeight(.heavy)
                                .foregroundColor(.black)
                                .opacity(animation ? 1 : 0)
                            
                            Text(card.title)
                                .font(.custom("Apothicaire Light Cd", size: 22))
                                .italic()
                                .fontWeight(.heavy)
                                .foregroundColor(.black)
                                .opacity(animation ? 1 : 0)
                            
                            Rectangle()
                                .frame(width: 80, height: 1)
                                .foregroundColor(.black.opacity(0.6))
                                .opacity(animation ? 1 : 0)
                            
                            Text(isKarmaCard ? karmaDescription : card.description)
                                .font(.custom("Apothicaire Light Cd", size: 18))
                                .foregroundColor(.black)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 25)
                                .opacity(animation ? 1 : 0)
                            
                            Button(action: {
                                dismissAction()
                            }) {
                                Text("Close")
                                    .font(.custom("Apothicaire Light Cd", size: 18))
                                    .foregroundColor(.white)
                                    .fontWeight(.heavy)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(AppTheme.darkAccent.opacity(0.7))                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .padding(.top, 15)
                            .opacity(animation ? 1 : 0)
                        }
                    }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0.86, green: 0.77, blue: 0.57).opacity(0.95))
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .scaleEffect(animation ? 1 : 0.8)
            .opacity(animation ? 1 : 0)
            .padding(.horizontal, 25)
        }
    }
}

#Preview {
    NavigationView {
        BirthCardView()
    }
}