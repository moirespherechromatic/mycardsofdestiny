import SwiftUI

struct VintageSplashView: View {
    let onStart: () -> Void
    
    @State private var showCards = false
    @State private var showButton = false
    @State private var cardScales: [CGFloat] = Array(repeating: 0.0, count: 7)
    @State private var cardOffsets: [CGSize] = Array(repeating: .zero, count: 7)
    @State private var cardRotations: [Double] = Array(repeating: 0, count: 7)
    
    // Card display names and their corresponding image file names (Queen of Spades in center)
    let cardNames = ["2♠", "5♣", "4♥", "Q♠", "4♠", "5♦", "2♥"]
    let cardImageNames = ["2s", "5c", "4h", "qs", "4s", "5d", "2h"] // qs.png is the center card (index 3)
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 60) {
                // Title Image - Using apptitle.png - APPEARS SOONER
                Group {
                    if let titleImage = UIImage(named: "apptitle") {
                        Image(uiImage: titleImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300) // Adjust size as needed
                            .opacity(showButton ? 1 : 0)
                            .animation(.easeInOut(duration: 1.2).delay(1.5), value: showButton) // Changed from 2.0 to 1.5
                    } else {
                        // Fallback to text if image not found
                        VStack(spacing: 4) {
                            Text("MY CARDS")
                                .font(.custom("Times New Roman", size: 36))
                                .fontWeight(.heavy)
                                .foregroundColor(AppTheme.primaryText)
                                .tracking(4)
                                .multilineTextAlignment(.center)
                                .opacity(showButton ? 1 : 0)
                                .animation(.easeInOut(duration: 1.0).delay(1.5), value: showButton) // Changed from 2.0 to 1.5
                            
                            Text("OF DESTINY")
                                .font(.custom("Times New Roman", size: 36))
                                .fontWeight(.heavy)
                                .foregroundColor(AppTheme.primaryText)
                                .tracking(4)
                                .multilineTextAlignment(.center)
                                .opacity(showButton ? 1 : 0)
                                .animation(.easeInOut(duration: 1.0).delay(1.7), value: showButton) // Changed from 2.2 to 1.7
                        }
                    }
                }
                .frame(maxWidth: .infinity) // Ensure centering
                
                // Card Animation Area
                ZStack {
                    // Dark oval background - BIGGER
                    Ellipse()
                        .fill(AppTheme.darkAccent)
                        .frame(width: 320, height: 240) // Increased from 280x200
                        .scaleEffect(showCards ? 1.0 : 0.3)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: showCards)
                    
                    // Cards - render other cards first, then center queen on top
                    ForEach(0..<cardNames.count, id: \.self) { index in
                        if index != 3 { // Render all other cards first
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
                    
                    // Render center queen last (on top)
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
                
                // Start Button
                Button(action: onStart) {
                    Text("Let's Begin")
                        .font(.custom("Apothicaire Light Cd", size: 20))
                        .fontWeight(.heavy)
                        .tracking(2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 18) // More vertical padding
                        .background(AppTheme.darkAccent.opacity(0.7)) // More faded background
                        .cornerRadius(30) // Bigger corner radius for larger button
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(1.0) // No additional scaling needed since we made it bigger
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                .opacity(showButton ? 1 : 0)
                .animation(.easeInOut(duration: 1.0).delay(2.5), value: showButton)
                
                Spacer()
            }
            .padding(.top, 80)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Step 1: Show center card immediately
        cardScales[3] = 1.0
        cardOffsets[3] = .zero
        cardRotations[3] = 0
        
        // Step 2: After delay, show background and spread other cards
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCards = true
            
            // Define positions for card spread
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
            
            // Animate other cards spreading out
            for index in 0..<cardNames.count {
                if index != 3 {
                    cardScales[index] = 1.0
                    cardOffsets[index] = positions[index]
                    cardRotations[index] = rotations[index]
                }
            }
        }
        
        // Step 3: Fade in button and title
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showButton = true
        }
    }
}

struct VintageCardImageView: View {
    let imageName: String
    let isCenter: Bool
    
    var body: some View {
        // Try multiple naming patterns
        Group {
            if let image = loadCardImage(imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill to crop but not too much
                    .frame(width: isCenter ? 121 : 91, height: isCenter ? 170 : 128) // Keep the 10% bigger size
                    .scaleEffect(1.05) // Much gentler crop - just enough to hide white borders
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
            } else {
                // Fallback: Show the image name for debugging
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: isCenter ? 121 : 91, height: isCenter ? 170 : 128)
                        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    VStack {
                        Text("Missing:")
                            .font(.system(size: 8))
                            .foregroundColor(.red)
                        Text(imageName)
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.black)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private func loadCardImage(_ baseName: String) -> UIImage? {
        // Try different naming patterns
        let namesToTry = [
            baseName,                    // ah
            baseName.uppercased(),       // AH
            "\(baseName).png",           // ah.png
            "\(baseName.uppercased()).png", // AH.png
            "card_\(baseName)",          // card_ah
            "Card_\(baseName)",          // Card_ah
        ]
        
        for name in namesToTry {
            if let image = UIImage(named: name) {
                return image
            }
        }
        
        return nil
    }
}

#Preview {
    VintageSplashView(onStart: {})
}
