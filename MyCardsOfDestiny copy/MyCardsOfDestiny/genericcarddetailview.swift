import SwiftUI

struct GenericCardDetailView: View {
    let card: Card
    @Binding var isShowing: Bool
    @Binding var animation: Bool
    let dismissAction: () -> Void
    let contentType: DetailContentType
    
    enum DetailContentType {
        case card(description: String?)
        case karma(description: String)
        case planetary(planet: String)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(animation ? AppConstants.Shadow.overlayOpacity : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAction()
                }
            
            ScrollView {
                HStack {
                    Spacer()
                    VStack(spacing: AppConstants.Spacing.large) {
                        cardImage
                        
                        if animation {
                            VStack(spacing: AppConstants.Spacing.medium) {
                                titleSection
                                divider
                                descriptionSection
                                closeButton
                            }
                        }
                    }
                    .padding(.vertical, AppConstants.Spacing.extraLarge)
                    .padding(.horizontal, AppConstants.Spacing.medium)
                    Spacer()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.modal)
                    .fill(Color(red: 0.86, green: 0.77, blue: 0.57).opacity(0.95))
            )
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.modal))
            .cardDetailAnimation(isVisible: $isShowing, isAnimated: $animation)
            .padding(.horizontal, AppConstants.Spacing.large)
        }
    }
    
    private var cardImage: some View {
        Group {
            switch contentType {
            case .planetary(let planet):
                if let planetImage = ImageManager.shared.loadPlanetImage(for: planet) {
                    Image(uiImage: planetImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: animation ? AppConstants.CardSizes.detailHeight : AppConstants.CardSizes.detailHeightCollapsed)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.cardDetail))
                        .cardShadow(isLarge: true)
                }
            default:
                if let cardImage = ImageManager.shared.loadCardImage(for: card) {
                    Image(uiImage: cardImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: animation ? AppConstants.CardSizes.detailHeight : AppConstants.CardSizes.detailHeightCollapsed)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.cardDetail))
                        .cardShadow(isLarge: true)
                }
            }
        }
    }
    
    @ViewBuilder
    private var titleSection: some View {
        switch contentType {
        case .card, .karma:
            VStack(spacing: AppConstants.Spacing.small) {
                Text(card.name.uppercased())
                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.extraLarge))
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .opacity(animation ? 1 : 0)
                
                Text(card.title)
                    .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.headline))
                    .italic()
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(animation ? 1 : 0)
            }
            
        case .planetary(let planet):
            let planetInfo = AppConstants.PlanetDescriptions.getDescription(for: planet)
            Text(planetInfo.title)
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.headline))
                .italic()
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(animation ? 1 : 0)
        }
    }
    
    private var divider: some View {
        Rectangle()
            .frame(width: 80, height: 1)
            .foregroundColor(.black.opacity(0.6))
            .opacity(animation ? 1 : 0)
    }
    
    @ViewBuilder
    private var descriptionSection: some View {
        switch contentType {
        case .card(let customDescription):
            Text(customDescription ?? card.description)
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, AppConstants.Spacing.tiny)
                .opacity(animation ? 1 : 0)
            
        case .karma(let description):
            Text(description)
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, AppConstants.Spacing.tiny)
                .opacity(animation ? 1 : 0)
            
        case .planetary(let planet):
            let planetInfo = AppConstants.PlanetDescriptions.getDescription(for: planet)
            Text(planetInfo.description)
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, AppConstants.Spacing.tiny)
                .opacity(animation ? 1 : 0)
        }
    }
    
    private var closeButton: some View {
        Button(action: dismissAction) {
            Text(AppConstants.Strings.close)
                .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.body))
                .foregroundColor(.white)
                .fontWeight(.heavy)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.button)
                        .fill(AppTheme.darkAccent.opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.button)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.top, AppConstants.Spacing.medium)
        .opacity(animation ? 1 : 0)
    }
}

struct DetailAnimationManager {
    static func showCard(
        card: Card,
        contentType: GenericCardDetailView.DetailContentType,
        showDetail: Binding<Bool>,
        detailCard: Binding<Card?>,
        detailContentType: Binding<GenericCardDetailView.DetailContentType?>,
        animation: Binding<Bool>
    ) {
        detailCard.wrappedValue = card
        detailContentType.wrappedValue = contentType
        
        withAnimation(.spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping)) {
            showDetail.wrappedValue = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Animation.detailShowDelay) {
            withAnimation(.easeInOut(duration: AppConstants.Animation.cardDetailDuration)) {
                animation.wrappedValue = true
            }
        }
    }
    
    static func dismissCard(
        showDetail: Binding<Bool>,
        animation: Binding<Bool>,
        detailCard: Binding<Card?>,
        detailContentType: Binding<GenericCardDetailView.DetailContentType?>
    ) {
        withAnimation(.easeInOut(duration: AppConstants.Animation.cardDetailFastDuration)) {
            animation.wrappedValue = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Animation.detailDismissDelay) {
            withAnimation(.easeOut(duration: AppConstants.Animation.cardDetailFastDuration)) {
                showDetail.wrappedValue = false
                detailCard.wrappedValue = nil
                detailContentType.wrappedValue = nil
            }
        }
    }
}