import SwiftUI

struct DCard: View {
    @StateObject private var viewModel = DCardViewModel()
    @ObservedObject private var dataManager = DataManager.shared
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
                    if DataManager.shared.explorationDate != nil {
                        dateExplorationIndicator
                    }
                    
                    mainTitleSection
                    todayCardSection
                    
                    LineBreak()
                    
                    lastCycleCardsSection
                    
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
            title: AppConstants.Strings.dailyInfluence,
            backAction: { presentationMode.wrappedValue.dismiss() },
            trailingContent: DataManager.shared.explorationDate != nil ? {
                AnyView(
                    Button(action: {
                        DataManager.shared.explorationDate = nil
                    }) {
                        Image(systemName: "calendar.badge.minus")
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }
                )
            } : nil
        )
        .onAppear {
            viewModel.loadDailyCard()
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
    
    private var dateExplorationIndicator: some View {
        VStack(spacing: AppConstants.Spacing.small) {
            Text("Exploring Date")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            if let date = DataManager.shared.explorationDate {
                Text(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.primaryText)
            }
        }
        .padding()
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    private var mainTitleSection: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Text("Daily Card")
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Text("Your daily influence and planetary energy")
                .font(AppTheme.Fonts.subtitle)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    private var todayCardSection: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            TappableCard(
                card: viewModel.dailyCard,
                onTap: {
                    showDailyCard()
                }
            )
            
            VStack(spacing: AppConstants.Spacing.small) {
                Text(viewModel.dailyCard.title)
                    .font(AppTheme.Fonts.cardTitle)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                
                if !viewModel.planetaryInfluence.isEmpty {
                    Text("\(viewModel.planetaryInfluence) Day")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.accentColor)
                }
            }
        }
    }
    
    private var lastCycleCardsSection: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            Text("Daily Progression")
                .font(AppTheme.Fonts.sectionHeader)
                .foregroundColor(AppTheme.Colors.primaryText)
            
            HStack(spacing: AppConstants.Spacing.medium) {
                // Yesterday
                VStack(spacing: AppConstants.Spacing.small) {
                    Text("Yesterday")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    TappableCard(
                        card: viewModel.yesterdayCard,
                        onTap: {
                            showYesterdayCard()
                        }
                    )
                }
                
                // Tomorrow
                VStack(spacing: AppConstants.Spacing.small) {
                    Text("Tomorrow")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    TappableCard(
                        card: viewModel.tomorrowCard,
                        onTap: {
                            showTomorrowCard()
                        }
                    )
                }
            }
        }
    }
    
    private func showDailyCard() {
        detailCard = viewModel.dailyCard
        detailContentType = .daily(planet: viewModel.planetaryInfluence)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    private func showYesterdayCard() {
        detailCard = viewModel.yesterdayCard
        detailContentType = .daily(planet: "Previous Day")
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            showCardDetail = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                cardDetailAnimation = true
            }
        }
    }
    
    private func showTomorrowCard() {
        detailCard = viewModel.tomorrowCard
        detailContentType = .daily(planet: "Next Day")
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

class DCardViewModel: ObservableObject {
    @Published var dailyCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var yesterdayCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var tomorrowCard: Card = Card(id: 1, name: "Loading...", value: "", suit: .hearts, title: "Loading...", description: "")
    @Published var planetaryInfluence: String = ""
    
    private let dataManager = DataManager.shared
    
    func loadDailyCard() {
        let calendar = Calendar.current
        let today = dataManager.explorationDate ?? Date()
        
        // Today's card
        let todayResult = dataManager.getDailyCard(for: today)
        dailyCard = todayResult.card ?? dataManager.getCard(by: todayResult.cardId)
        planetaryInfluence = todayResult.planet
        
        // Yesterday's card
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
            let yesterdayResult = dataManager.getDailyCard(for: yesterday)
            yesterdayCard = yesterdayResult.card ?? dataManager.getCard(by: yesterdayResult.cardId)
        }
        
        // Tomorrow's card
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
            let tomorrowResult = dataManager.getDailyCard(for: tomorrow)
            tomorrowCard = tomorrowResult.card ?? dataManager.getCard(by: tomorrowResult.cardId)
        }
    }
}

#Preview {
    DCard()
}

