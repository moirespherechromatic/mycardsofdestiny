import SwiftUI

struct DailyCardView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var calculator = CardCalculationService()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var detailCard: DailyCardResult? = nil
    @State private var tappedCardPosition: DayPeriod? = nil
    @State private var cardDetailAnimation = false
    @State private var isPlanetaryCard = false
    
    private var calculationDate: Date {
        let baseDate = dataManager.explorationDate ?? Date()
        
        // Simply use the system timezone's start of day
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: baseDate)
    }
    
    private var userCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    // Helper to get a specific day relative to calculation date
    private func getDateForDayOffset(_ offset: Int) -> Date {
        return userCalendar.date(byAdding: .day, value: offset, to: calculationDate) ?? calculationDate
    }
    
    // Helper function to format card names with only first letter capitalized
    private func formatCardName(_ name: String) -> String {
        return name.prefix(1).uppercased() + name.dropFirst().lowercased()
    }
    
    enum DayPeriod: String, CaseIterable {
        case yesterday = "Yesterday"
        case today = "Today"
        case tomorrow = "Tomorrow"
    }
    
    private var birthCard: Card {
        // Use user's calendar to extract birth date components in proper timezone
        let components = userCalendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    private var yesterdayCard: DailyCardResult {
        let yesterday = getDateForDayOffset(-1)
        return calculator.getDailyCard(birthDate: dataManager.userProfile.birthDate, birthCard: birthCard.id, targetDate: yesterday)
    }
    
    private var todayCard: DailyCardResult {
        return calculator.getDailyCard(birthDate: dataManager.userProfile.birthDate, birthCard: birthCard.id, targetDate: calculationDate)
    }
    
    private var tomorrowCard: DailyCardResult {
        let tomorrow = getDateForDayOffset(1)
        return calculator.getDailyCard(birthDate: dataManager.userProfile.birthDate, birthCard: birthCard.id, targetDate: tomorrow)
    }
    
    private func getDayCard(for period: DayPeriod) -> DailyCardResult {
        switch period {
        case .yesterday: return yesterdayCard
        case .today: return todayCard
        case .tomorrow: return tomorrowCard
        }
    }
    
    private func getPlanetDescription(_ planet: String) -> (title: String, description: String) {
        switch planet.lowercased() {
        case "mercury":
            return ("The Messenger", "Mercury governs communication, intellect, and quick thinking. This planet influences your ability to express ideas, learn new concepts, and adapt to changing situations during your daily cycle.")
        case "venus":
            return ("The Lover", "Venus rules love, beauty, and harmony. This planet affects your relationships, artistic expression, and ability to attract and appreciate beauty during your daily cycle.")
        case "mars":
            return ("The Warrior", "Mars represents action, energy, and drive. This planet influences your motivation, physical strength, and ability to take initiative during your daily cycle.")
        case "jupiter":
            return ("The Teacher", "Jupiter governs expansion, wisdom, and growth. This planet affects your philosophical outlook, learning opportunities, and ability to see the bigger picture during your daily cycle.")
        case "saturn":
            return ("The Taskmaster", "Saturn represents discipline, responsibility, and life lessons. This planet influences your ability to build lasting structures and learn from experience during your daily cycle.")
        case "uranus":
            return ("The Revolutionary", "Uranus governs innovation, rebellion, and sudden changes. This planet affects your need for freedom, originality, and breakthrough moments during your daily cycle.")
        case "neptune":
            return ("The Mystic", "Neptune rules dreams, intuition, and spirituality. This planet influences your imagination, psychic abilities, and connection to the divine during your daily cycle.")
        case "pluto":
            return ("The Transformer", "Pluto represents transformation, power, and rebirth. This planet affects deep psychological changes and your ability to regenerate and evolve during your daily cycle.")
        default:
            return ("The Unknown", "This planetary influence brings unique energies and lessons into your daily cycle experience.")
        }
    }
    
    // Dismiss card detail view with animation
    private func dismissCardDetail() {
        withAnimation(.easeInOut(duration: 0.5)) {
            cardDetailAnimation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                showCardDetail = false
                tappedCardPosition = nil
                isPlanetaryCard = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background color that extends fully
            Color(red: 0.86, green: 0.77, blue: 0.57)
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    // Date indicator when exploring specific date
                    if dataManager.explorationDate != nil {
                        dateExplorationIndicator
                    }
                    
                    // Main title section
                    mainTitleSection
                    
                    // Today's Card and Planet Section
                    todayCardSection
                    
                    // Section separator
                    if let linebreakImage = UIImage(named: "linedesign") {
                        Image(uiImage: linebreakImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                    }
                    
                    // Last Cycle Cards Section
                    lastCycleCardsSection
                    
                    // Section separator - bottom
                    if let linebreakImage = UIImage(named: "linedesignd") ?? UIImage(named: "linedesignd") {
                        Image(uiImage: linebreakImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(red: 0.86, green: 0.77, blue: 0.57))
            .environment(\.font, .custom("Apothicaire Light Cd", size: 16))
            
            // Card Detail Overlay
            if showCardDetail, let cardResult = detailCard {
                ZStack {
                    Color.black.opacity(cardDetailAnimation ? 0.5 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissCardDetail()
                        }
                    
                    DailyCardDetailView(
                        cardResult: cardResult,
                        isShowing: $showCardDetail,
                        animation: $cardDetailAnimation,
                        dismissAction: dismissCardDetail,
                        isPlanetaryCard: isPlanetaryCard,
                        getPlanetDescription: getPlanetDescription
                    )
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .navigationTitle("Daily Influence")
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
                Text("Daily Influence")
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
    
    private var mainTitleSection: some View {
        VStack(spacing: 8) {
            Text(formatCardName(todayCard.card.name).uppercased())
                .font(.custom("Apothicaire Light Cd", size: 28))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
            
            Text("as your \(todayCard.planet) day")
                .font(.custom("Apothicaire Light Cd", size: 20))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
    }
    
    private var todayCardSection: some View {
        HStack(spacing: 40) {
            // Today's Card
            Button(action: {
                detailCard = getDayCard(for: .today)
                tappedCardPosition = .today
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
                if let uiImage = loadCardImage(for: todayCard.card) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 156, height: 229)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                }
            }
            
            // Planet Card
            Button(action: {
                detailCard = getDayCard(for: .today)
                tappedCardPosition = .today
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
                if let planetImage = loadPlanetImage(for: todayCard.planet) {
                    Image(uiImage: planetImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 156, height: 229)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                } else {
                    // Fallback if planet image doesn't load
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        
                        VStack {
                            Text("☿")
                                .font(.custom("Apothicaire Light Cd", size: 64))
                                .foregroundColor(.black)
                                .fontWeight(.heavy)
                            
                            Text(todayCard.planet.uppercased())
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
    
    private var lastCycleCardsSection: some View {
        VStack(spacing: 16) {
            // Side by side cards for Yesterday and Tomorrow
            HStack(spacing: 40) {
                // Yesterday Card
                VStack(spacing: 8) {
                    Text("Your Last Cycle")
                        .font(.custom("Apothicaire Light Cd", size: 18))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        detailCard = getDayCard(for: .yesterday)
                        tappedCardPosition = .yesterday
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
                        if let uiImage = loadCardImage(for: yesterdayCard.card) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 176)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                
                // Tomorrow Card
                VStack(spacing: 8) {
                    Text("Your Next Cycle")
                        .font(.custom("Apothicaire Light Cd", size: 18))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        detailCard = getDayCard(for: .tomorrow)
                        tappedCardPosition = .tomorrow
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
                        if let uiImage = loadCardImage(for: tomorrowCard.card) {
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
    
    private var dateExplorationIndicator: some View {
        VStack(spacing: 4) {
            Text("Exploring Cards for")
                .font(.custom("Apothicaire Light Cd", size: 16))
                .foregroundColor(.black)
            
            Text(calculationDate, style: .date)
                .font(.custom("Apothicaire Light Cd", size: 18))
                .fontWeight(.heavy)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func loadCardImage(for card: Card) -> UIImage? {
        let imageName = card.imageName
        return UIImage(named: imageName) ?? UIImage(named: "Resources/Images/\(imageName)")
    }
    
    private func loadPlanetImage(for planet: String) -> UIImage? {
        let imageName = planet.lowercased()
        return UIImage(named: imageName) ?? UIImage(named: "Resources/Images/\(imageName)")
    }
}

// Card Detail View - shown when a card is tapped
struct DailyCardDetailView: View {
    let cardResult: DailyCardResult
    @Binding var isShowing: Bool
    @Binding var animation: Bool
    var dismissAction: () -> Void
    var isPlanetaryCard: Bool = false
    var getPlanetDescription: ((String) -> (title: String, description: String))?
    
    // Helper function to format card names with only first letter capitalized
    private func formatCardName(_ name: String) -> String {
        return name.prefix(1).uppercased() + name.dropFirst().lowercased()
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                HStack {
                    Spacer()
                    VStack(spacing: 25) {
                    // Card image - large size (show planetary image if it's a planetary card)
                    if isPlanetaryCard,
                       let planetaryImage = UIImage(named: cardResult.planet.lowercased()) {
                        Image(uiImage: planetaryImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: animation ? 300 : 150)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    } else if let uiImage = UIImage(named: cardResult.card.imageName) ?? UIImage(named: "Resources/Images/\(cardResult.card.imageName)") {
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
                            if isPlanetaryCard {
                                Text(getPlanetDescription?(cardResult.planet).title ?? "Planetary Influence")
                                    .font(.custom("Apothicaire Light Cd", size: 22))
                                    .italic()
                                    .fontWeight(.heavy)
                                    .foregroundColor(.black)
                                    .opacity(animation ? 1 : 0)
                            } else {
                                Text(cardResult.card.name.uppercased())
                                    .font(.custom("Apothicaire Light Cd", size: 32))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.black)
                                    .opacity(animation ? 1 : 0)
                                
                                Text(cardResult.card.title)
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
                            if isPlanetaryCard {
                                Text(getPlanetDescription?(cardResult.planet).description ?? "This planetary influence affects the energy and themes of your daily cycle.")
                                    .font(.custom("Apothicaire Light Cd", size: 18))
                                    .foregroundColor(.black)
                                    .fontWeight(.heavy)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 25)
                                    .opacity(animation ? 1 : 0)
                            } else {
                                Text(cardResult.card.description)
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
        DailyCardView()
    }
}
