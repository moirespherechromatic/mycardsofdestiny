import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager: DataManager = DataManager.shared
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingProfileSheet = false
    
    var body: some View {
        Group {
            if dataManager.isProfileComplete {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 0) {
                            headerView
                            welcomeSection
                            cardsGrid
                        }
                        .padding(.bottom, AppConstants.Spacing.sectionSpacing)
                    }
                    .background(Color(red: 0.91, green: 0.82, blue: 0.63))
                    .ignoresSafeArea(edges: .bottom)
                    .navigationBarHidden(true)
                    .onAppear {
                        viewModel.startHomeAnimations()
                    }
                }
                .sheet(isPresented: $showingProfileSheet) {
                    ProfileSheet()
                }
            } else {
                ProfileSetupBlockingView()
            }
        }
        .errorFallback(message: viewModel.errorMessage)
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
            .padding(.horizontal, AppConstants.Spacing.medium)
            .padding(.vertical, AppConstants.Spacing.medium)
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 0) {
            Text("\(AppConstants.Strings.welcome), \(dataManager.userProfile.name.isEmpty ? "Guest" : dataManager.userProfile.name)")
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.extraLarge))
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .padding(.bottom, AppConstants.Spacing.medium)
            
            LineBreak(height: 22)
                .frame(width: 280)
                .padding(.top, AppConstants.Spacing.small)
                .padding(.bottom, AppConstants.Spacing.small)
        }
    }
    
    private var cardsGrid: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                SectionHeader(AppConstants.Strings.yourDailyCard, fontSize: AppConstants.FontSizes.title)
                    .tracking(2)
                Spacer()
            }
            .padding(.bottom, AppConstants.Spacing.small)
            
            VStack(spacing: 0) {
                Spacer(minLength: 30)
                
                DailyCardLarge()
                    .padding(.bottom, 14)
                
                Spacer(minLength: 0)
                
                Text(dataManager.isDailyCardRevealed ? "Tap to View" : AppConstants.Strings.tapToReveal)
                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.headline))
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, AppConstants.Spacing.titleSpacing)
                    .scaleEffect(dataManager.isDailyCardRevealed ? 1.0 : viewModel.pulseScale)
                    .opacity(viewModel.showTapToReveal ? 1 : 0)
                
                LineBreak("linedesignd", height: 22)
                    .frame(width: 280)
                    .padding(.bottom, AppConstants.Spacing.sectionSpacing)
            }
            .frame(height: 350)
            
            HStack(spacing: AppConstants.Spacing.small) {
                ActualCardTileSmall(
                    cardImageName: viewModel.cardToImageName(viewModel.userBirthCard),
                    title: AppConstants.Strings.birthCard,
                    destination: BCard()
                )
                
                ActualCardTileSmall(
                    cardImageName: viewModel.cardToImageName(viewModel.userYearlyCard),
                    title: AppConstants.Strings.yearlyCard,
                    destination: YCard()
                )
                
                ActualCardTileSmall(
                    cardImageName: viewModel.cardToImageName(viewModel.user52DayCard),
                    title: AppConstants.Strings.fiftyTwoDayCycle,
                    destination: FCard()
                )
            }
            .padding(.horizontal, AppConstants.Spacing.medium)
            .padding(.top, AppConstants.Spacing.large)
        }
    }
}

struct ProfileSetupBlockingView: View {
    @StateObject private var dataManager: DataManager = DataManager.shared
    @State private var showingProfileSheet = true
    
    var body: some View {
        ZStack {
            Color(red: 0.91, green: 0.82, blue: 0.63)
                .ignoresSafeArea()
            
            VStack(spacing: AppConstants.Spacing.sectionSpacing) {
                Spacer()
                
                Group {
                    if let titleImage = UIImage(named: "apptitle") {
                        Image(uiImage: titleImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 280)
                    } else {
                        VStack(spacing: 4) {
                            Text("MY CARDS")
                                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.extraLarge))
                                .fontWeight(.heavy)
                                .tracking(3)
                            Text("OF DESTINY")
                                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.extraLarge))
                                .fontWeight(.heavy)
                                .tracking(3)
                        }
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    }
                }
                
                VStack(spacing: AppConstants.Spacing.medium) {
                    Text("Welcome to Cards of Destiny!")
                        .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.headline))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text("To reveal your personalized cards and begin your mystical journey, please set up your profile first.")
                        .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.callout))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppConstants.Spacing.medium)
                }
                
                Button("Set Up Your Profile") {
                    showingProfileSheet = true
                }
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .padding(.horizontal, AppConstants.Spacing.extraLarge)
                .padding(.vertical, AppConstants.Spacing.medium)
                .background(Color.black)
                .cornerRadius(AppConstants.CornerRadius.button)
                .cardShadow()
                
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
    @StateObject private var dataManager: DataManager = DataManager.shared
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var dailyCardViewModel = DailyCardViewModel()
    
    var body: some View {
        NavigationLink(destination: DCard()) {
            Group {
                if dataManager.isDailyCardRevealed {
                    // Show the actual daily card - use the same logic as DailyCardView
                    let todayCardResult = dailyCardViewModel.todayCard
                    let todayCard = todayCardResult.card ?? dataManager.getCard(by: todayCardResult.cardId)
                    let cardImageName = viewModel.cardToImageName(todayCard)
                    
                    if let cardImage = ImageManager.shared.loadCardImage(named: cardImageName) {
                        Image(uiImage: cardImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: AppConstants.CardSizes.extraLarge.width, height: AppConstants.CardSizes.extraLarge.height)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.cardLarge))
                            .cardShadow(isLarge: true)
                    } else {
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.cardLarge)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: AppConstants.CardSizes.extraLarge.width, height: AppConstants.CardSizes.extraLarge.height)
                            .overlay(
                                Text("Card Image\nNot Found")
                                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.caption))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            )
                            .cardShadow(isLarge: true)
                    }
                } else {
                    // Show the card back
                    if let cardBackImage = UIImage(named: "cardback") {
                        Image(uiImage: cardBackImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: AppConstants.CardSizes.extraLarge.width, height: AppConstants.CardSizes.extraLarge.height)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.cardLarge))
                            .cardShadow(isLarge: true)
                    } else {
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.cardLarge)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: AppConstants.CardSizes.extraLarge.width, height: AppConstants.CardSizes.extraLarge.height)
                            .overlay(
                                Text("Card Back\nNot Found")
                                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.caption))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            )
                            .cardShadow(isLarge: true)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActualCardTileSmall<Destination: View>: View {
    let cardImageName: String
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: AppConstants.Spacing.small) {
                Group {
                    if let cardImage = ImageManager.shared.loadCardImage(named: cardImageName) {
                        Image(uiImage: cardImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: AppConstants.CardSizes.small.width, height: AppConstants.CardSizes.small.height)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.card))
                            .cardShadow()
                    } else {
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.card)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: AppConstants.CardSizes.small.width, height: AppConstants.CardSizes.small.height)
                            .cardShadow()
                            .overlay(
                                VStack {
                                    Text(AppConstants.Strings.missingImage)
                                        .font(.custom("Apothicaire Light Cd", size: 6))
                                        .foregroundColor(.black)
                                    Text(cardImageName)
                                        .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.caption))
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                }
                            )
                    }
                }
                
                Text(title)
                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
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