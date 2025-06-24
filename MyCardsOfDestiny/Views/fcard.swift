import SwiftUI

struct FCard: View {
    @StateObject private var viewModel = FCardViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCardDetail = false
    @State private var detailCard: Card? = nil
    @State private var detailContentType: GenericCardDetailView.DetailContentType? = nil
    @State private var cardDetailAnimation = false
    
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
            
            if showCardDetail, let card = detailCard, let contentType = detailContentType {
                GenericCardDetailView(
                    card: card,
                    isShowing: $showCardDetail,
                    animation: $cardDetailAnimation,
                    dismissAction: dismissCardDetail,
                    contentType: contentType
                )
            }
        }
        .standardNavigation(
            title: AppConstants.Strings.fiftyTwoDayInfluence,
            backAction: { presentationMode.wrappedValue.dismiss() },
            trailingContent: DataManager.shared.explorationDate != nil ? {
                AnyView(
                    Button(AppConstants.Strings.reset) {
                        DataManager.shared.explorationDate = nil
                    }
                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.callout))
                    .foregroundColor(.black)
                )
            } : nil
        )
        .onAppear {
            viewModel.load52DayCard()
        }
        .sheet(isPresented: $showCardDetail) {
            if let card = detailCard, let contentType = detailContentType {
                GenericCardDetailView(
                    card: card,
                    isShowing: $showCardDetail,
                    animation: $cardDetailAnimation,
                    dismissAction: dismissCardDetail,
                    contentType: contentType
                )
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Text("52-Day Cycle")
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text("Your current 52-day planetary period")
                .font(AppTheme.Fonts.subtitle)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
            
            Text("Period \(viewModel.currentPeriod) of 7")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.accentColor)
        }
    }
    
    private var mainCardsSection: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            TappableCard(
                card: viewModel.currentCycleCard,
                onTap: {
                    showCurrentCycleCard()
                }
            )
            
            Text(viewModel.currentCycleCard.title)
                .font(AppTheme.Fonts.cardTitle)
                .foregroundColor(AppTheme.Colors.primaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    private var periodCardsSection: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Text("Cycle Progression")
                .font(AppTheme.Fonts.sectionHeader)
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: AppConstants.Spacing.medium) {
                // Previous Cycle
                VStack(spacing: AppConstants.Spacing.small) {
                    Text("Previous Cycle")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    TappableCard(
                        card: viewModel.previousCycleCard,
                        onTap: {
                            showPreviousCycleCard()
                        }
                    )
                }
                
                // Next Cycle
                VStack(spacing: AppConstants.Spacing.small) {
                    Text("Next Cycle")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    TappableCard(
                        card: viewModel.nextCycleCard,
                        onTap: {
                            showNextCycleCard()
                        }
                    )
                }
            }
        }
    }
    
    private func showCurrentCycleCard() {
        detailCard = viewModel.currentCycleCard
        detailContentType = .fiftyTwoDay(period: viewModel.currentPeriod)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    private func showPreviousCycleCard() {
        detailCard = viewModel.previousCycleCard
        detailContentType = .fiftyTwoDay(period: max(1, viewModel.currentPeriod - 1))
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    private func showNextCycleCard() {
        detailCard = viewModel.nextCycleCard
        detailContentType = .fiftyTwoDay(period: min(7, viewModel.currentPeriod + 1))
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    private func dismissCardDetail() {
        withAnimation(.easeInOut(duration: 0.4)) {
            cardDetailAnimation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.4)) {
                showCardDetail = false
            }
        }
    }
}

class FCardViewModel: ObservableObject {
    @Published var currentCycleCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var previousCycleCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var nextCycleCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var currentPeriod: Int = 1
    
    private let dataManager = DataManager.shared
    
    func load52DayCard() {
        currentPeriod = dataManager.getCurrentPeriod()
        currentCycleCard = dataManager.get52DayCard()
        
        // Calculate previous and next cycle cards
        let birthCard = dataManager.getBirthCard()
        let age = dataManager.getCurrentAge()
        
        // Previous cycle (period - 1, minimum 1)
        let prevPeriod = max(1, currentPeriod - 1)
        if let prevCardId = calculateCycleCard(birthCard: birthCard.id, age: age, period: prevPeriod) {
            previousCycleCard = dataManager.getCard(by: prevCardId)
        }
        
        // Next cycle (period + 1, maximum 7)
        let nextPeriod = min(7, currentPeriod + 1)
        if let nextCardId = calculateCycleCard(birthCard: birthCard.id, age: age, period: nextPeriod) {
            nextCycleCard = dataManager.getCard(by: nextCardId)
        }
    }
    
    private func calculateCycleCard(birthCard: Int, age: Int, period: Int) -> Int? {
        // Use the same calculation service that DataManager uses
        let calculationService = CardCalculationService()
        return calculationService.fc(birthCard: birthCard, age: age, period: period)
    }
}

#Preview {
    FCard()
}

