import SwiftUI

struct AppConstants {
    
    // MARK: - Card Sizes
    struct CardSizes {
        static let extraLarge = CGSize(width: 202, height: 284)
        static let large = CGSize(width: 156, height: 229)
        static let medium = CGSize(width: 120, height: 176)
        static let small = CGSize(width: 91, height: 128)
        static let tiny = CGSize(width: 80, height: 120)
        
        static let detailHeight: CGFloat = 300
        static let detailHeightCollapsed: CGFloat = 150
    }
    
    // MARK: - Animation
    struct Animation {
        static let cardDetailDuration: Double = 0.5
        static let cardDetailFastDuration: Double = 0.4
        static let springResponse: Double = 0.55
        static let springDamping: Double = 0.8
        static let fadeInDuration: Double = 1.0
        static let pulseScale: CGFloat = 1.08
        static let pulseDuration: Double = 0.6
        
        static let detailShowDelay: Double = 0.2
        static let detailDismissDelay: Double = 0.4
        
        // Accessibility animations
        static let reducedMotionDuration: Double = 0.2
        static let reducedMotionSpring: Double = 0.3
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 40
        
        static let cardSpacing: CGFloat = 40
        static let sectionSpacing: CGFloat = 20
        static let titleSpacing: CGFloat = 8
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let card: CGFloat = 8
        static let cardLarge: CGFloat = 12
        static let cardDetail: CGFloat = 16
        static let modal: CGFloat = 25
        static let button: CGFloat = 25
        static let small: CGFloat = 10
    }
    
    // MARK: - Font Sizes (Dynamic Type Support)
    struct FontSizes {
        static func dynamicSize(for textStyle: UIFont.TextStyle) -> CGFloat {
            UIFont.preferredFont(forTextStyle: textStyle).pointSize
        }
        
        // Base sizes for custom font
        static let extraLarge: CGFloat = 36
        static let large: CGFloat = 28
        static let title: CGFloat = 24
        static let headline: CGFloat = 22
        static let subheadline: CGFloat = 20
        static let body: CGFloat = 18
        static let callout: CGFloat = 16
        static let caption: CGFloat = 12
        
        // Dynamic sizes
        static var dynamicExtraLarge: CGFloat {
            dynamicSize(for: .largeTitle)
        }
        static var dynamicLarge: CGFloat {
            dynamicSize(for: .title1)
        }
        static var dynamicTitle: CGFloat {
            dynamicSize(for: .title2)
        }
        static var dynamicHeadline: CGFloat {
            dynamicSize(for: .headline)
        }
        static var dynamicBody: CGFloat {
            dynamicSize(for: .body)
        }
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let cardOpacity: Double = 0.15
        static let cardRadius: CGFloat = 3
        static let cardOffset = CGSize(width: 0, height: 2)
        
        static let detailOpacity: Double = 0.3
        static let detailRadius: CGFloat = 10
        static let detailOffset = CGSize(width: 0, height: 5)
        
        static let overlayOpacity: Double = 0.5
    }
    
    // MARK: - Strings (Localized/Accessible)
    struct Strings {
        static let close = "Close"
        static let reset = "Reset"
        static let tapToReveal = "Tap To Reveal"
        static let welcome = "Welcome"
        static let yourDailyCard = "YOUR DAILY CARD"
        static let karmaConnections = "Karmic Connections"
        static let lastCycle = "Your Last Cycle"
        static let nextCycle = "Your Next Cycle"
        static let birthCard = "Birth Card"
        static let yearlyCard = "Yearly Card"
        static let fiftyTwoDayCycle = "52-Day Cycle"
        static let dailyInfluence = "Daily Influence"
        static let yearlyInfluence = "Yearly Influence"
        static let fiftyTwoDayInfluence = "52-Day Influence"
        static let exploring = "Exploring Cards for"
        static let missingImage = "Missing:"
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        // Minimum touch target size (Apple HIG requirement)
        static let minimumTouchTarget: CGFloat = 44
        
        // VoiceOver Labels
        struct Labels {
            static func cardLabel(rank: String, suit: String) -> String {
                "\(rank) of \(suit)"
            }
            static let shareButton = "Share card"
            static let backButton = "Go back"
            static let settingsButton = "Settings"
            static let closeModal = "Close card details"
            static let revealCard = "Reveal daily card"
            static let viewCard = "View card details"
        }
        
        // VoiceOver Hints
        struct Hints {
            static let doubleTapToView = "Double tap to view details"
            static let doubleTapToReveal = "Double tap to reveal"
            static let doubleTapToShare = "Double tap to share"
            static let doubleTapToClose = "Double tap to close"
            static let doubleTapToOpen = "Double tap to open"
        }
        
        // Identifiers for UI Testing
        struct Identifiers {
            static let dailyCard = "daily_card"
            static let birthCard = "birth_card"
            static let yearlyCard = "yearly_card"
            static let shareButton = "share_button"
            static let settingsButton = "settings_button"
            static let backButton = "back_button"
            static let closeButton = "close_button"
        }
        
        // Color Contrast (WCAG AA compliance)
        struct Contrast {
            static let minimumNormalText: Double = 4.5
            static let minimumLargeText: Double = 3.0
        }
    }
    
    // MARK: - Planet Descriptions
    struct PlanetDescriptions {
        static func getDescription(for planet: String) -> (title: String, description: String) {
            switch planet.lowercased() {
            case "mercury":
                return ("The Messenger", "Mercury governs communication, intellect, and quick thinking. This planet influences your ability to express ideas, learn new concepts, and adapt to changing situations.")
            case "venus":
                return ("The Lover", "Venus rules love, beauty, and harmony. This planet affects your relationships, artistic expression, and ability to attract and appreciate beauty.")
            case "mars":
                return ("The Warrior", "Mars represents action, energy, and drive. This planet influences your motivation, physical strength, and ability to take initiative.")
            case "jupiter":
                return ("The Teacher", "Jupiter governs expansion, wisdom, and growth. This planet affects your philosophical outlook, learning opportunities, and ability to see the bigger picture.")
            case "saturn":
                return ("The Taskmaster", "Saturn represents discipline, responsibility, and life lessons. This planet influences your ability to build lasting structures and learn from experience.")
            case "uranus":
                return ("The Revolutionary", "Uranus governs innovation, rebellion, and sudden changes. This planet affects your need for freedom, originality, and breakthrough moments.")
            case "neptune":
                return ("The Mystic", "Neptune rules dreams, intuition, and spirituality. This planet influences your imagination, psychic abilities, and connection to the divine.")
            case "pluto":
                return ("The Transformer", "Pluto represents transformation, power, and rebirth. This planet affects deep psychological changes and your ability to regenerate and evolve.")
            default:
                return ("The Unknown", "This planetary influence brings unique energies and lessons into your experience.")
            }
        }
    }
}
