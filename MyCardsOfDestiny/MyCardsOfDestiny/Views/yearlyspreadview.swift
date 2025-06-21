import SwiftUI

struct YearlySpreadView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var calculator = CardCalculationService()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var detailCard: Card? = nil
    @State private var tappedCardPosition: YearPeriod? = nil
    @State private var cardDetailAnimation = false
    
    private var calculationDate: Date {
        dataManager.explorationDate ?? Date()
    }
    
    enum YearPeriod: String, CaseIterable {
        case last = "Last Year"
        case current = "This Year"
        case next = "Next Year"
    }
    
    private var birthCard: Card {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    private func getYearlyCard(for period: YearPeriod) -> Card {
        let age = calculator.getAge(birthDate: dataManager.userProfile.birthDate, onDate: calculationDate)
        let adjustedAge: Int
        
        switch period {
        case .last: adjustedAge = age - 1
        case .current: adjustedAge = age
        case .next: adjustedAge = age + 1
        }
        
        let cardId = calculator.getLongRangeCard(birthCard: birthCard.id, age: adjustedAge)
        return dataManager.getCard(by: cardId)
    }
    
    private var currentYearCard: Card {
        getYearlyCard(for: .current)
    }
    
    // Dismiss card detail view with animation
    private func dismissCardDetail() {
        withAnimation(.easeInOut(duration: 0.4)) {
            cardDetailAnimation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.4)) {
                showCardDetail = false
                tappedCardPosition = nil
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.86, green: 0.77, blue: 0.57)
                .ignoresSafeArea(.all)
                
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Main Current Year Card
                    mainCardSection
                    
                    // Linebreak graphic below main card
                    if let linebreakImage = UIImage(named: "linedesign") {
                        Image(uiImage: linebreakImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(.vertical, 8)
                    }
                    
                    // Last/Next Year Cards Section
                    yearlyCardsSection
                    
                    // Section separator below cards
                    if let linebreakImage = UIImage(named: "linedesignd") {
                        Image(uiImage: linebreakImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(red: 0.86, green: 0.77, blue: 0.57))
            .environment(\.font, .custom("Apothicaire Light Cd", size: 16))
            
            // Card Detail Overlay
            if showCardDetail, let card = detailCard {
                ZStack {
                    Color.black.opacity(cardDetailAnimation ? 0.5 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissCardDetail()
                        }
                    
                    YearlyCardDetailView(
                        card: card,
                        isShowing: $showCardDetail,
                        animation: $cardDetailAnimation,
                        dismissAction: dismissCardDetail
                    )
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .navigationTitle("Yearly Influence")
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
                Text("Yearly Influence")
                    .font(.custom("Apothicaire Light Cd", size: 22))
                    .foregroundColor(.black)
                    .fontWeight(.heavy)
            }
            
            if dataManager.explorationDate != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        dataManager.explorationDate = nil
                    }
                    .font(.custom("Apothicaire Light Cd", size: 16))
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    // Header section showing current card name and subtitle
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(currentYearCard.name.uppercased())
                .font(.custom("Apothicaire Light Cd", size: 28))
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text(currentYearCard.title.lowercased())
                .font(.custom("Apothicaire Light Cd", size: 20))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
    }
    
    private var mainCardSection: some View {
        Button(action: {
            detailCard = currentYearCard
            tappedCardPosition = .current
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                showCardDetail = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    cardDetailAnimation = true
                }
            }
        }) {
            if let uiImage = loadCardImage(for: currentYearCard) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 156, height: 229)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            }
        }
    }
    
    private var yearlyCardsSection: some View {
        VStack(spacing: 16) {
            // Side by side cards for Last Year and Next Year
            HStack(spacing: 40) {
                // Last Year Card
                VStack(spacing: 8) {
                    Text("Your Last Cycle")
                        .font(.custom("Apothicaire Light Cd", size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        detailCard = getYearlyCard(for: .last)
                        tappedCardPosition = .last
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                            showCardDetail = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                cardDetailAnimation = true
                            }
                        }
                    }) {
                        if let uiImage = loadCardImage(for: getYearlyCard(for: .last)) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 176)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                
                // Next Year Card
                VStack(spacing: 8) {
                    Text("Your Next Cycle")
                        .font(.custom("Apothicaire Light Cd", size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        detailCard = getYearlyCard(for: .next)
                        tappedCardPosition = .next
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                            showCardDetail = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                cardDetailAnimation = true
                            }
                        }
                    }) {
                        if let uiImage = loadCardImage(for: getYearlyCard(for: .next)) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 176)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        }
                    }
                }
            }
        }
    }
    
    private func loadCardImage(for card: Card) -> UIImage? {
        let imageName = card.imageName
        return UIImage(named: imageName) ?? UIImage(named: "Resources/Images/\(imageName)")
    }
}

// Card Detail View - shown when a card is tapped
struct YearlyCardDetailView: View {
    let card: Card
    @Binding var isShowing: Bool
    @Binding var animation: Bool
    var dismissAction: () -> Void
    
    var body: some View {
        ZStack {
            ScrollView {
                HStack {
                    Spacer()
                    VStack(spacing: 25) {
                    // Card image - large size
                    if let uiImage = UIImage(named: card.imageName) ?? UIImage(named: "Resources/Images/\(card.imageName)") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: animation ? 300 : 150)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // Card information - only visible when fully animated
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
                            
                            // Divider line
                            Rectangle()
                                .frame(width: 80, height: 1)
                                .foregroundColor(.black.opacity(0.6))
                                .opacity(animation ? 1 : 0)
                            
                            // Description text (now scrollable with the entire view)
                            Text(card.description)
                                .font(.custom("Apothicaire Light Cd", size: 18))
                                .foregroundColor(.black)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 25)
                                .opacity(animation ? 1 : 0)
                            
                            // Close button
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
        YearlySpreadView()
    }
}
