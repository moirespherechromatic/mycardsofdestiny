import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var calculator = CardCalculationService()
    @State private var showingProfileSheet = false
    
    // Animation states
    @State private var showTapToReveal = false
    @State private var pulseScale = 1.0 // Start at normal size
    
    // Calculate the user's actual cards
    private var userBirthCard: Card {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: dataManager.userProfile.birthDate)
        let cardId = calculator.getBirthCard(month: components.month ?? 1, day: components.day ?? 1)
        return dataManager.getCard(by: cardId)
    }
    
    private var userYearlyCard: Card {
        let age = calculator.getAge(birthDate: dataManager.userProfile.birthDate, onDate: Date())
        let cardId = calculator.getLongRangeCard(birthCard: userBirthCard.id, age: age)
        return dataManager.getCard(by: cardId)
    }
    
    private var user52DayCard: Card {
        let age = calculator.getAge(birthDate: dataManager.userProfile.birthDate, onDate: Date())
        let currentPeriod = calculator.getCurrentPeriod(birthDate: dataManager.userProfile.birthDate, targetDate: Date())
        let cardId = calculator.get52DayCard(birthCard: userBirthCard.id, age: age, period: currentPeriod)
        return dataManager.getCard(by: cardId)
    }
    
    // Convert Card to image filename
    private func cardToImageName(_ card: Card) -> String {
        let value = String(describing: card.value).lowercased()
        let suit = String(describing: card.suit).lowercased()
        
        let suitChar: String
        switch suit {
        case "hearts": suitChar = "h"
        case "diamonds": suitChar = "d"
        case "clubs": suitChar = "c"
        case "spades": suitChar = "s"
        default: suitChar = "s"
        }
        
        let valueChar: String
        switch value {
        case "ace": valueChar = "a"
        case "jack": valueChar = "j"
        case "queen": valueChar = "q"
        case "king": valueChar = "k"
        case "two": valueChar = "2"
        case "three": valueChar = "3"
        case "four": valueChar = "4"
        case "five": valueChar = "5"
        case "six": valueChar = "6"
        case "seven": valueChar = "7"
        case "eight": valueChar = "8"
        case "nine": valueChar = "9"
        case "ten": valueChar = "10"
        default: valueChar = value
        }
        
        return "\(valueChar)\(suitChar)"
    }
    
    var body: some View {
        Group {
            if dataManager.isProfileComplete {
                // Show main app when profile is complete
                NavigationView {
                    ScrollView {
                        VStack(spacing: 0) {
                            headerView
                            welcomeSection
                            cardsGrid
                        }
                        .padding(.bottom, 20) // Added bottom padding to create more space
                    }
                    .background(Color(red: 0.91, green: 0.82, blue: 0.63)) // Consistent background color
                    .ignoresSafeArea(edges: .bottom)
                    .navigationBarHidden(true)
                    .onAppear {
                        // Start animations when view appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeIn(duration: 1.0)) {
                                showTapToReveal = true
                            }
                            
                            // Start smooth pulse animation after fade-in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                // First grow smoothly
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    pulseScale = 1.08 // Grow to 108% size
                                }
                                
                                // Then smoothly shrink back
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        pulseScale = 1.0 // Return to normal size
                                    }
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingProfileSheet) {
                    ProfileSheet()
                }
            } else {
                // Block access - show only profile setup
                ProfileSetupBlockingView()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                Button(action: { showingProfileSheet = true }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // Updated Welcome Section with single line "Welcome, [Name]"
    private var welcomeSection: some View {
        VStack(spacing: 0) {
            Text("Welcome, \(dataManager.userProfile.name.isEmpty ? "Guest" : dataManager.userProfile.name)")
                .font(.custom("Apothicaire Light Cd", size: 36))
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .padding(.bottom, 15) // Reduced padding before line design by half
            
            // Custom linedesign image (upper line)
            Group {
                if let linedesignImage = UIImage(named: "linedesign") {
                    Image(uiImage: linedesignImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 280, height: 22)
                } else {
                    // Fallback to original line if image not found
                    Rectangle()
                        .frame(width: 280, height: 1)
                        .foregroundColor(Color.black.opacity(0.3))
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 10) // Increased spacing between line and YOUR DAILY CARD
        }
    }
    
    private var explorationIndicator: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.darkAccent)
                .font(.caption)
            
            Text("Exploring: \(dataManager.explorationDate!, style: .date)")
                .font(.custom("Times New Roman", size: 14))
                .foregroundColor(AppTheme.darkAccent)
                .fontWeight(.heavy)
            
            Spacer()
            
            Button("Return to Today") {
                dataManager.explorationDate = nil
            }
            .font(.custom("Times New Roman", size: 14))
            .fontWeight(.heavy)
            .foregroundColor(AppTheme.darkAccent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.cardBackground)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(AppTheme.darkAccent.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(AppTheme.darkAccent.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 0)
    }
    
    private var cardsGrid: some View {
        VStack(spacing: 0) { // Changed spacing to 0 for more control
            // Section title - MOVED UP and CENTER JUSTIFIED
            HStack {
                Spacer()
                Text("YOUR DAILY CARD")
                    .font(.custom("Apothicaire Light Cd", size: 24))
                    .fontWeight(.heavy) // Changed to light weight to match
                    .tracking(2)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.top, 0)
            .padding(.bottom, 10) // Increased from 25 to 30 to push card down more
            
            // Large Daily Card - Face Down (Hidden)
            VStack(spacing: 0) {
                Spacer(minLength: 30) // Increased spacing to push card down
                
                DailyCardLarge()
                    .padding(.bottom, 14) // Reduced from 30 to 20 to move "Tap To Reveal" up
                
                Spacer(minLength: 0) // Removed minimum height
                
                // Tap To Reveal text with fade-in and smooth pulse animation
                Text("Tap To Reveal")
                    .font(.custom("Apothicaire Light Cd", size: 22))
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8) // Reduced from 10 to 5 to move it up
                    .scaleEffect(pulseScale) // Smooth pulse animation with variable
                    .opacity(showTapToReveal ? 1 : 0) // Fade in
                
                // Custom linedesignd image (lower line) UNDER "Tap To Reveal"
                Group {
                    if let linedesigndImage = UIImage(named: "linedesignd") {
                        Image(uiImage: linedesigndImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 280, height: 22) // 10% larger vertically, wider than "YOUR DAILY CARD"
                    } else {
                        // Fallback to original line if image not found
                        Rectangle()
                            .frame(width: 280, height: 1)
                            .foregroundColor(Color.black.opacity(0.3))
                    }
                }
                .padding(.bottom, 20) // Added padding below line break to create more space
            }
            .frame(height: 350) // Reduced height to move everything up
            
            // Row of 3 Smaller Card Images - CLOSER TOGETHER
            HStack(spacing: 10) { // Reduced from 15 to 10
                ActualCardTileSmall(
                    cardImageName: cardToImageName(userBirthCard),
                    title: "Birth Card",
                    destination: AnyView(BirthCardView())
                )
                
                ActualCardTileSmall(
                    cardImageName: cardToImageName(userYearlyCard),
                    title: "Yearly Card",
                    destination: AnyView(YearlySpreadView())
                )
                
                ActualCardTileSmall(
                    cardImageName: cardToImageName(user52DayCard),
                    title: "52-Day Cycle",
                    destination: AnyView(FiftyTwoDayCycleView())
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 25) // Fine-tuned to match screenshot precisely
        }
    }
    
    private var infoTip: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(AppTheme.darkAccent.opacity(0.7))
                .font(.caption)
            
            Text("Tap the calendar icon to explore cards for any date")
                .font(.custom("Times New Roman", size: 13))
                .foregroundColor(AppTheme.secondaryText)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}

struct ProfileSetupBlockingView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingProfileSheet = true
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.91, green: 0.82, blue: 0.63) // Consistent background color
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                Group {
                    if let titleImage = UIImage(named: "apptitle") {
                        Image(uiImage: titleImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 280)
                    } else {
                        VStack(spacing: 4) {
                            Text("MY CARDS")
                                .font(.custom("Apothicaire Light Cd", size: 32))
                                .fontWeight(.heavy)
                                .tracking(3)
                            Text("OF DESTINY")
                                .font(.custom("Apothicaire Light Cd", size: 32))
                                .fontWeight(.heavy)
                                .tracking(3)
                        }
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    }
                }
                
                // Message
                VStack(spacing: 16) {
                    Text("Welcome to Cards of Destiny!")
                        .font(.custom("Apothicaire Light Cd", size: 22))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text("To reveal your personalized cards and begin your mystical journey, please set up your profile first.")
                        .font(.custom("Apothicaire Light Cd", size: 16))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Setup Button
                Button("Set Up Your Profile") {
                    showingProfileSheet = true
                }
                .font(.custom("Apothicaire Light Cd", size: 18))
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color.black)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingProfileSheet) {
            ProfileSheet()
        }
        .onAppear {
            showingProfileSheet = true
        }
    }
}

struct DailyCardLarge: View {
    var body: some View {
        NavigationLink(destination: AnyView(DailyCardView())) {
            Group {
                if let cardBackImage = UIImage(named: "cardback") {
                    Image(uiImage: cardBackImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 202, height: 284) // 10% larger than original
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                } else {
                    // Fallback if cardback.png not found
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 202, height: 284) // 10% larger than original
                        .overlay(
                            Text("Card Back\nNot Found")
                                .font(.custom("Apothicaire Light Cd", size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActualCardTileSmall: View {
    let cardImageName: String
    let title: String
    let destination: AnyView
    
    private func loadCardImage(_ imageName: String) -> UIImage? {
        // Try different naming patterns
        let namesToTry = [
            imageName,                    // ah
            imageName.uppercased(),       // AH
            "\(imageName).png",           // ah.png
            "\(imageName.uppercased()).png" // AH.png
        ]
        
        for name in namesToTry {
            if let image = UIImage(named: name) {
                return image
            }
        }
        
        return nil
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) { // Increased from 8 to 12 for better spacing with larger text
                // Actual card image - 10% SMALLER than before
                Group {
                    if let cardImage = loadCardImage(cardImageName) {
                        Image(uiImage: cardImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 91, height: 128) // Reduced by 10%
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 3)
                    } else {
                        // Fallback placeholder with debug info
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 91, height: 128) // Reduced by 10%
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 3)
                            .overlay(
                                VStack {
                                    Text("Missing:")
                                        .font(.custom("Apothicaire Light Cd", size: 6))
                                        .foregroundColor(.black)
                                    Text(cardImageName)
                                        .font(.custom("Apothicaire Light Cd", size: 8))
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                }
                            )
                    }
                }
                
                // Page name underneath - 10% LARGER
                Text(title)
                    .font(.custom("Apothicaire Light Cd", size: 18)) // Increased by 10% from 16
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}
