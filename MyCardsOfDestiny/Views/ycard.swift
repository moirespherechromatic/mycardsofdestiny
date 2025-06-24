import SwiftUI

struct YCard: View {
    @StateObject private var viewModel = YCardViewModel()
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
                    mainCardSection
                    
                    LineBreak()
                    
                    yearlyCardsSection
                    
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
            title: AppConstants.Strings.yearlyInfluence,
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
            viewModel.loadYearlyCard()
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
            Text("Yearly Card")
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text("Your yearly influence and life theme")
                .font(AppTheme.Fonts.subtitle)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
            
            Text("Age \(viewModel.currentAge)")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.accentColor)
        }
    }
    
    private var mainCardSection: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            TappableCard(
                card: viewModel.currentYearCard,
                onTap: {
                    showCurrentYearCard()
                }
            )
            
            Text(viewModel.currentYearCard.title)
                .font(AppTheme.Fonts.cardTitle)
                .foregroundColor(AppTheme.Colors.primaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    private var yearlyCardsSection: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Text("Yearly Progression")
                .font(AppTheme.Fonts.sectionHeader)
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: AppConstants.Spacing.medium) {
                // Last Year
                VStack(spacing: AppConstants.Spacing.small) {
                    Text("Last Year")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    TappableCard(
                        card: viewModel.lastYearCard,
                        onTap: {
                            showLastYearCard()
                        }
                    )
                }
                
                // Next Year
                VStack(spacing: AppConstants.Spacing.small) {
                    Text("Next Year")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    TappableCard(
                        card: viewModel.nextYearCard,
                        onTap: {
                            showNextYearCard()
                        }
                    )
                }
            }
        }
    }
    
    private func showCurrentYearCard() {
        detailCard = viewModel.currentYearCard
        detailContentType = .yearly(age: viewModel.currentAge)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    private func showLastYearCard() {
        detailCard = viewModel.lastYearCard
        detailContentType = .yearly(age: max(0, viewModel.currentAge - 1))
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    private func showNextYearCard() {
        detailCard = viewModel.nextYearCard
        detailContentType = .yearly(age: viewModel.currentAge + 1)
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

class YCardViewModel: ObservableObject {
    @Published var currentYearCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var lastYearCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var nextYearCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var currentAge: Int = 0
    
    private let dataManager = DataManager.shared
    
    func loadYearlyCard() {
        currentAge = dataManager.getCurrentAge()
        currentYearCard = dataManager.getYearlyCard()
        
        // Calculate last and next year cards
        let birthCard = dataManager.getBirthCard()
        
        // Last year (age - 1, minimum 0)
        let lastAge = max(0, currentAge - 1)
        if let lastCardId = calculateYearlyCard(birthCard: birthCard.id, age: lastAge) {
            lastYearCard = dataManager.getCard(by: lastCardId)
        }
        
        // Next year (age + 1)
        let nextAge = currentAge + 1
        if let nextCardId = calculateYearlyCard(birthCard: birthCard.id, age: nextAge) {
            nextYearCard = dataManager.getCard(by: nextCardId)
        }
    }
    
    private func calculateYearlyCard(birthCard: Int, age: Int) -> Int? {
        // Use the same calculation service that DataManager uses
        let calculationService = CardCalculationService()
        return calculationService.yc(birthCard: birthCard, age: age)
    }
}

#Preview {
    YCard()
}

