import SwiftUI

// MARK: - Card Animation Modifiers
struct CardDetailAnimation: ViewModifier {
    @Binding var isVisible: Bool
    @Binding var isAnimated: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimated ? 1 : 0.8)
            .opacity(isAnimated ? 1 : 0)
            .animation(.easeInOut(duration: AppConstants.Animation.cardDetailDuration), value: isAnimated)
    }
}

struct CardTapAnimation: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        Button(action: action) {
            content
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Navigation Modifiers
struct StandardNavigation: ViewModifier {
    let title: String
    let hasBackButton: Bool
    let backAction: (() -> Void)?
    let trailingContent: (() -> AnyView)?
    
    init(title: String, hasBackButton: Bool = true, backAction: (() -> Void)? = nil, trailingContent: (() -> AnyView)? = nil) {
        self.title = title
        self.hasBackButton = hasBackButton
        self.backAction = backAction
        self.trailingContent = trailingContent
    }
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(hasBackButton)
            .toolbar {
                if hasBackButton {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: backAction ?? {}) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.custom("Apothicaire Light Cd", size: AppConstants.FontSizes.title))
                        .foregroundColor(.black)
                        .fontWeight(.heavy)
                }
                
                if let trailingContent = trailingContent {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        trailingContent()
                    }
                }
            }
    }
}

// MARK: - Card Shadow Modifier
struct CardShadow: ViewModifier {
    let isLarge: Bool
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: .black.opacity(isLarge ? AppConstants.Shadow.detailOpacity : AppConstants.Shadow.cardOpacity),
                radius: isLarge ? AppConstants.Shadow.detailRadius : AppConstants.Shadow.cardRadius,
                x: isLarge ? AppConstants.Shadow.detailOffset.width : AppConstants.Shadow.cardOffset.width,
                y: isLarge ? AppConstants.Shadow.detailOffset.height : AppConstants.Shadow.cardOffset.height
            )
    }
}

// MARK: - Error Handling Modifier
struct ErrorFallback: ViewModifier {
    let errorMessage: String
    let retryAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .constant(!errorMessage.isEmpty)) {
                if let retryAction = retryAction {
                    Button("Retry", action: retryAction)
                }
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
    }
}

// MARK: - Convenience Extensions
extension View {
    func cardDetailAnimation(isVisible: Binding<Bool>, isAnimated: Binding<Bool>) -> some View {
        modifier(CardDetailAnimation(isVisible: isVisible, isAnimated: isAnimated))
    }
    
    func cardTap(action: @escaping () -> Void) -> some View {
        modifier(CardTapAnimation(action: action))
    }
    
    func standardNavigation(
        title: String,
        hasBackButton: Bool = true,
        backAction: (() -> Void)? = nil,
        trailingContent: (() -> AnyView)? = nil
    ) -> some View {
        modifier(StandardNavigation(
            title: title,
            hasBackButton: hasBackButton,
            backAction: backAction,
            trailingContent: trailingContent
        ))
    }
    
    func cardShadow(isLarge: Bool = false) -> some View {
        modifier(CardShadow(isLarge: isLarge))
    }
    
    func errorFallback(message: String, retryAction: (() -> Void)? = nil) -> some View {
        modifier(ErrorFallback(errorMessage: message, retryAction: retryAction))
    }
}