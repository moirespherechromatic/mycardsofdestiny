import SwiftUI

struct VintageSplashView: View {
    let onStart: () -> Void
    
    @State private var showCards = false
    @State private var showButton = false
    @State private var cardScales: [CGFloat] = Array(repeating: 0.0, count: 7)
    @State private var cardOffsets: [CGSize] = Array(repeating: .zero, count: 7)
    @State private var cardRotations: [Double] = Array(repeating: 0, count: 7)
    
    let cardNames = ["2♠", "5♣", "4♥", "Q♠", "4♠", "5♦", "2♥"]
    let cardImageNames = ["2s", "5c", "4h", "qs", "4s", "5d", "2h"]
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 60) {
                titleSection
                cardAnimationArea
                startButton
                Spacer()
            }
            .padding(.top, 80)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private var titleSection: some View {
        Group {
            if let titleImage = UIImage(named: "apptitle") {
                Image(uiImage: titleImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300)
                    .opacity(showButton ? 1 : 0)
                    .animation(.easeInOut(duration: 1.2).delay(1.5), value: showButton)
            } else {
                VStack(spacing: 4) {
                    Text("MY CARDS")
                        .font(.custom("Times New Roman", size: AppConstants.FontSizes.extraLarge))
                        
                        .foregroundColor(AppTheme.primaryText)
                        .tracking(4)
                        .multilineTextAlignment(.center)
                        .opacity(showButton ? 1 : 0)
                        .animation(.easeInOut(duration: 1.0).delay(1.5), value: showButton)
                    
                    Text("OF DESTINY")
                        .font(.custom("Times New Roman", size: AppConstants.FontSizes.extraLarge))
                        
                        .foregroundColor(AppTheme.primaryText)
                        .tracking(4)
                        .multilineTextAlignment(.center)
                        .opacity(showButton ? 1 : 0)
                        .animation(.easeInOut(duration: 1.0).delay(1.7), value: showButton)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var cardAnimationArea: some View {
        ZStack {
            Ellipse()
                .fill(AppTheme.darkAccent)
                .frame(width: 320, height: 240)
                .scaleEffect(showCards ? 1.0 : 0.3)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: showCards)
            
            ForEach(0..<cardNames.count, id: \.self) { index in
                if index != 3 {
                    VintageCardImageView(
                        imageName: cardImageNames[index],
                        isCenter: false
                    )
                    .scaleEffect(cardScales[index])
                    .offset(cardOffsets[index])
                    .rotationEffect(.degrees(cardRotations[index]))
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.6)
                        .delay(Double(index) * 0.1 + 1.0),
                        value: cardScales[index]
                    )
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.6)
                        .delay(Double(index) * 0.1 + 1.0),
                        value: cardOffsets[index]
                    )
                }
            }
            
            VintageCardImageView(
                imageName: cardImageNames[3],
                isCenter: true
            )
            .scaleEffect(cardScales[3])
            .offset(cardOffsets[3])
            .rotationEffect(.degrees(cardRotations[3]))
            .animation(
                .spring(response: 0.8, dampingFraction: 0.6),
                value: cardScales[3]
            )
        }
        .frame(height: 250)
    }
    
    private var startButton: some View {
        Button(action: onStart) {
            Text("Let's Begin")
                .font(.custom("Iowan Old Style", size: AppConstants.FontSizes.subheadline))
                
                .tracking(0.5)
                .foregroundColor(.white)
                .padding(.horizontal, 50)
                .padding(.vertical, AppConstants.Spacing.medium).background(AppTheme.darkAccent.opacity(0.7))
                .cornerRadius(AppConstants.CornerRadius.button)
                .multilineTextAlignment(.center)
        }
        .scaleEffect(1.0)
        .cardShadow(isLarge: true)
        .opacity(showButton ? 1 : 0)
        .animation(.easeInOut(duration: 1.0).delay(2.5), value: showButton)
    }
    
    private func startAnimation() {
        cardScales[3] = 1.0
        cardOffsets[3] = .zero
        cardRotations[3] = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCards = true
            
            let positions: [CGSize] = [
                CGSize(width: -120, height: -30),
                CGSize(width: -80, height: 40),
                CGSize(width: -40, height: -60),
                CGSize(width: 0, height: 0),
                CGSize(width: 40, height: -60),
                CGSize(width: 80, height: 40),
                CGSize(width: 120, height: -30)
            ]
            
            let rotations: [Double] = [-25, -15, -10, 0, 10, 15, 25]
            
            for index in 0..<cardNames.count {
                if index != 3 {
                    cardScales[index] = 1.0
                    cardOffsets[index] = positions[index]
                    cardRotations[index] = rotations[index]
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showButton = true
        }
    }
}

struct VintageCardImageView: View {
    let imageName: String
    let isCenter: Bool
    
    var body: some View {
        Group {
            if let image = ImageManager.shared.loadCardImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: isCenter ? 121 : 91,
                        height: isCenter ? 170 : 128
                    )
                    .scaleEffect(1.05)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small))
                    .cardShadow()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small)
                        .fill(Color.white)
                        .frame(
                            width: isCenter ? 121 : 91,
                            height: isCenter ? 170 : 128
                        )
                        .cardShadow()
                    
                    VStack {
                        Text(AppConstants.Strings.missingImage)
                            .font(.system(size: AppConstants.FontSizes.caption))
                            .foregroundColor(.red)
                        Text(imageName)
                            .font(.system(size: AppConstants.FontSizes.caption, weight: .heavy))
                            .foregroundColor(.black)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small))
            }
        }
    }
}

#Preview {
    VintageSplashView(onStart: {})
}
