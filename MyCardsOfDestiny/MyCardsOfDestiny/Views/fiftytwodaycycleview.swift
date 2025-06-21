import SwiftUI

struct FiftyTwoDayCycleView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var calculator = CardCalculationService()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var detailCard: Card? = nil
    @State private var tappedCardPosition: CyclePeriod? = nil
    @State private var cardDetailAnimation = false
    @State private var isPlanetaryCard = false
    
    private var calculationDate: Date {
        dataManager.explorationDate ?? Date()
    }
    
    enum CyclePeriod: String, CaseIterable {
        case last = "Last Period"
        case current = "This Period"
        case next = "Next Period"
        case planetary = "Planetary Period"
    }
    
    private var birthCard: Card {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    private var currentPeriodNumber: Int {
        calculator.getCurrentPeriod(birthDate: dataManager.userProfile.birthDate, targetDate: calculationDate)
    }
    
    private func getPeriodCard(for period: CyclePeriod) -> Card {
        let age = calculator.getAge(birthDate: dataManager.userProfile.birthDate, onDate: calculationDate)
        let periodNumber: Int
        
        switch period {
        case .last: periodNumber = currentPeriodNumber == 1 ? 7 : currentPeriodNumber - 1
        case .current: periodNumber = currentPeriodNumber
        case .next: periodNumber = currentPeriodNumber == 7 ? 1 : currentPeriodNumber + 1
        case .planetary: periodNumber = currentPeriodNumber
        }
        
        let cardId = calculator.get52DayCard(birthCard: birthCard.id, age: age, period: periodNumber)
        return dataManager.getCard(by: cardId)
    }
    
    private var currentPeriodCard: Card {
        getPeriodCard(for: .current)
    }
    
    private var planetaryPeriod: String {
        let planets = ["Error", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
        return planets.indices.contains(currentPeriodNumber) ? planets[currentPeriodNumber] : "Unknown"
    }
    
    private var planetaryImageName: String {
        return planetaryPeriod.lowercased()
    }
    
    private func getPlanetDescription(_ planet: String) -> (title: String, description: String) {
        switch planet.lowercased() {
        case "mercury":
            return ("The Messenger", "Mercury governs communication, intellect, and quick thinking. This planet influences your ability to express ideas, learn new concepts, and adapt to changing situations during your 52-day cycle.")
        case "venus":
            return ("The Lover", "Venus rules love, beauty, and harmony. This planet affects your relationships, artistic expression, and ability to attract and appreciate beauty during your 52-day cycle.")
        case "mars":
            return ("The Warrior", "Mars represents action, energy, and drive. This planet influences your motivation, physical strength, and ability to take initiative during your 52-day cycle.")
        case "jupiter":
            return ("The Teacher", "Jupiter governs expansion, wisdom, and growth. This planet affects your philosophical outlook, learning opportunities, and ability to see the bigger picture during your 52-day cycle.")
        case "saturn":
            return ("The Taskmaster", "Saturn represents discipline, responsibility, and life lessons. This planet influences your ability to build lasting structures and learn from experience during your 52-day cycle.")
        case "uranus":
            return ("The Revolutionary", "Uranus governs innovation, rebellion, and sudden changes. This planet affects your need for freedom, originality, and breakthrough moments during your 52-day cycle.")
        case "neptune":
            return ("The Mystic", "Neptune rules dreams, intuition, and spirituality. This planet influences your imagination, psychic abilities, and connection to the divine during your 52-day cycle.")
        case "pluto":
            return ("The Transformer", "Pluto represents transformation, power, and rebirth. This planet affects deep psychological changes and your ability to regenerate and evolve during your 52-day cycle.")
        default:
            return ("The Unknown", "This planetary influence brings unique energies and lessons into your 52-day cycle experience.")
        }
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
                isPlanetaryCard = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background - fill entire screen
            Color(red: 0.86, green: 0.77, blue: 0.57)
                .ignoresSafeArea(.all)
                
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section with Current Card Name and Planetary Period
                    headerSection
                    
                    // Main Current Period and Planetary Cards Section
                    mainCardsSection
                    
                    // Linebreak graphic below main cards
                    if let linebreakImage = UIImage(named: "linedesign") {
                        Image(uiImage: linebreakImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(.vertical, 8)
                    }
                    
                    // Last/Next Period Cards Section
                    periodCardsSection
                    
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
                    
                    CycleCardDetailView(
                        card: card,
                        isShowing: $showCardDetail,
                        animation: $cardDetailAnimation,
                        dismissAction: dismissCardDetail,
                        planetaryPeriod: isPlanetaryCard ? planetaryPeriod : nil,
                        isPlanetaryCard: isPlanetaryCard,
                        getPlanetDescription: getPlanetDescription
                    )
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .navigationTitle("52-Day Influence")
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
                Text("52-Day Influence")
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
    
    // Header section showing current card name and planetary period
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(currentPeriodCard.name.uppercased())
                .font(.custom("Apothicaire Light Cd", size: 28))
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("in your \(planetaryPeriod) phase")
                .font(.custom("Apothicaire Light Cd", size: 20))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
    }
    
    private var mainCardsSection: some View {
        VStack(spacing: 24) {
            // Side by side cards for Current Period and Planetary Period
            HStack(spacing: 40) {
                // Current Period Card
                Button(action: {
                    detailCard = currentPeriodCard
                    tappedCardPosition = .current
                    isPlanetaryCard = false
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                        showCardDetail = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            cardDetailAnimation = true
                        }
                    }
                }) {
                    if let uiImage = loadCardImage(for: currentPeriodCard) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 156, height: 229)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    }
                }
                
                // Planetary Period Card
                Button(action: {
                    detailCard = currentPeriodCard // Use same card for planetary influence
                    tappedCardPosition = .planetary
                    isPlanetaryCard = true
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                        showCardDetail = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            cardDetailAnimation = true
                        }
                    }
                }) {
                    if let planetaryImage = UIImage(named: planetaryImageName) {
                        Image(uiImage: planetaryImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 156, height: 229)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    } else {
                        // Fallback to text-based planetary display
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                            
                            VStack {
                                Text("♂")
                                    .font(.custom("Apothicaire Light Cd", size: 64))
                                    .foregroundColor(.black)
                                    .fontWeight(.heavy)
                                
                                Text(planetaryPeriod)
                                    .font(.custom("Apothicaire Light Cd", size: 18))
                                    .foregroundColor(.black)
                                    .fontWeight(.heavy)
                            }
                        }
                        .frame(width: 156, height: 229)
                    }
                }
            }
        }
    }
    
    private var periodCardsSection: some View {
        VStack(spacing: 16) {
            // Side by side cards for Last and Next Cycles
            HStack(spacing: 40) {
                // Last Cycle Card
                VStack(spacing: 8) {
                    Text("Your Last Cycle")
                        .font(.custom("Apothicaire Light Cd", size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        detailCard = getPeriodCard(for: .last)
                        tappedCardPosition = .last
                        isPlanetaryCard = false
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                            showCardDetail = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                cardDetailAnimation = true
                            }
                        }
                    }) {
                        if let uiImage = loadCardImage(for: getPeriodCard(for: .last)) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 176)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                
                // Next Cycle Card
                VStack(spacing: 8) {
                    Text("Your Next Cycle")
                        .font(.custom("Apothicaire Light Cd", size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        detailCard = getPeriodCard(for: .next)
                        tappedCardPosition = .next
                        isPlanetaryCard = false
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                            showCardDetail = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                cardDetailAnimation = true
                            }
                        }
                    }) {
                        if let uiImage = loadCardImage(for: getPeriodCard(for: .next)) {
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
struct CycleCardDetailView: View {
    let card: Card
    @Binding var isShowing: Bool
    @Binding var animation: Bool
    var dismissAction: () -> Void
    var planetaryPeriod: String?
    var isPlanetaryCard: Bool = false
    var getPlanetDescription: ((String) -> (title: String, description: String))?
    
    var body: some View {
        ZStack {
            ScrollView {
                HStack {
                    Spacer()
                    VStack(spacing: 25) {
                    // Card image - large size (show planetary image if it's a planetary card)
                    if isPlanetaryCard, let planetaryPeriod = planetaryPeriod,
                       let planetaryImage = UIImage(named: planetaryPeriod.lowercased()) {
                        Image(uiImage: planetaryImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: animation ? 300 : 150)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    } else if let uiImage = UIImage(named: card.imageName) ?? UIImage(named: "Resources/Images/\(card.imageName)") {
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
                            if isPlanetaryCard, let planetaryPeriod = planetaryPeriod {
                                Text(getPlanetDescription?(planetaryPeriod).title ?? "Planetary Influence")
                                    .font(.custom("Apothicaire Light Cd", size: 22))
                                    .italic()
                                    .fontWeight(.heavy)
                                    .foregroundColor(.black)
                                    .opacity(animation ? 1 : 0)
                            } else {
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
                            }
                            
                            // Divider line
                            Rectangle()
                                .frame(width: 80, height: 1)
                                .foregroundColor(.black.opacity(0.6))
                                .opacity(animation ? 1 : 0)
                            
                            // Description text (now scrollable with the entire view)
                            if isPlanetaryCard, let planetaryPeriod = planetaryPeriod {
                                Text(getPlanetDescription?(planetaryPeriod).description ?? "This planetary period influences the energy and themes of your current 52-day cycle.")
                                    .font(.custom("Apothicaire Light Cd", size: 18))
                                    .foregroundColor(.black)
                                    .fontWeight(.heavy)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 25)
                                    .opacity(animation ? 1 : 0)
                            } else {
                                Text(card.description)
                                    .font(.custom("Apothicaire Light Cd", size: 18))
                                    .foregroundColor(.black)
                                    .fontWeight(.heavy)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 25)
                                    .opacity(animation ? 1 : 0)
                            }
                            
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
        FiftyTwoDayCycleView()
    }
}
