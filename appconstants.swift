import SwiftUI

struct AppConstants {
    
    struct CardSizes {
        static let extraLarge = CGSize(width: 202, height: 284) // unchanged

        static let aspect: CGFloat = 3.5 / 2.5 // ≈ 1.4

        static let largeWidth: CGFloat = 156
        static let large = CGSize(width: largeWidth, height: largeWidth * aspect) // ≈ 156 × 218.4

        static let mediumWidth: CGFloat = 120
        static let medium = CGSize(width: mediumWidth, height: mediumWidth * aspect) // ≈ 120 × 168

        static let smallWidth: CGFloat = 91
        static let small = CGSize(width: smallWidth, height: smallWidth * aspect) // ≈ 91 × 127.4

        static let tinyWidth: CGFloat = 80
        static let tiny = CGSize(width: tinyWidth, height: tinyWidth * aspect) // ≈ 80 × 112

        static let detailHeight: CGFloat = 300
        static let detailHeightCollapsed: CGFloat = 150

        // Aliases for clarity
        static let portraitLarge = AppConstants.CardSizes.large
        static let portraitMedium = AppConstants.CardSizes.medium
        static let portraitSmall = AppConstants.CardSizes.small
        static let portraitTiny = AppConstants.CardSizes.tiny
    }

    struct CardStyle {
        /// Returns the recommended corner radius constant for a given card size.
        /// Uses width comparisons with a small tolerance to avoid floating errors.
        static func cornerRadius(for size: CGSize) -> CGFloat {
            let w = size.width
            // Large silhouettes
            if abs(w - AppConstants.CardSizes.extraLarge.width) < 0.5 ||
               abs(w - AppConstants.CardSizes.large.width) < 0.5 {
                return AppConstants.CornerRadius.cardLarge
            }
            // Medium/small silhouettes
            if abs(w - AppConstants.CardSizes.medium.width) < 0.5 ||
               abs(w - AppConstants.CardSizes.small.width) < 0.5 ||
               abs(w - AppConstants.CardSizes.tiny.width) < 0.5 {
                return AppConstants.CornerRadius.card
            }
            // Default to small radius if unknown
            return AppConstants.CornerRadius.card
        }
    }

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
        
        static let reducedMotionDuration: Double = 0.2
        static let reducedMotionSpring: Double = 0.3
    }
    
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
    
    struct CornerRadius {
        static let card: CGFloat = 12
        static let cardLarge: CGFloat = 12
        static let cardDetail: CGFloat = 16
        static let modal: CGFloat = 25
        static let button: CGFloat = 25
        static let small: CGFloat = 10
    }
    
    struct FontSizes {
        static func dynamicSize(for textStyle: UIFont.TextStyle) -> CGFloat {
            UIFont.preferredFont(forTextStyle: textStyle).pointSize
        }
        
        static let extraLarge: CGFloat = 32
        static let large: CGFloat = 25
        static let title: CGFloat = 21
        static let headline: CGFloat = 20
        static let subheadline: CGFloat = 18
        static let body: CGFloat = 16
        static let callout: CGFloat = 14
        static let caption: CGFloat = 11
        
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
    
    struct Shadow {
        static let cardOpacity: Double = 0.15
        static let cardRadius: CGFloat = 3
        static let cardOffset = CGSize(width: 0, height: 2)
        
        static let detailOpacity: Double = 0.3
        static let detailRadius: CGFloat = 10
        static let detailOffset = CGSize(width: 0, height: 5)
        
        static let overlayOpacity: Double = 0.5
    }
    
    struct Strings {
        static let close = "Close"
        static let reset = "Reset"
        static let tapToReveal = "Tap To Reveal"
        static let welcome = "Welcome"
        static let yourDailyCard = "TODAY'S CYCLE"
        static let karmaConnections = "Life Connections"
        static let lastCycle = "Your Last Cycle"
        static let nextCycle = "Your Next Cycle"
        static let birthCard = "Your Sun Card"
        static let yearlyCard = "Solar Cycle"
        static let fiftyTwoDayCycle = "Astral Cycle"
        static let dailyInfluence = "Today's Cycle"
        static let yearlyInfluence = "Solar Cycle"
        static let fiftyTwoDayInfluence = "Astral Cycle"
        static let exploring = "Exploring Cards for"
        static let missingImage = "Missing:"
    }
    
    struct Accessibility {
        static let minimumTouchTarget: CGFloat = 44
        
        struct Labels {
            static func cardLabel(rank: String, suit: String) -> String {
                "\(rank) of \(suit)"
            }
            static let shareButton = "Share card"
            static let backButton = "Go back"
            static let settingsButton = "Settings"
            static let closeModal = "Close card details"
            static let revealCard = "Reveal Today's Cycle"
            static let viewCard = "View card details"
        }
        
        struct Hints {
            static let doubleTapToView = "Double tap to view details"
            static let doubleTapToReveal = "Double tap to reveal"
            static let doubleTapToShare = "Double tap to share"
            static let doubleTapToClose = "Double tap to close"
            static let doubleTapToOpen = "Double tap to open"
        }
        
        struct Identifiers {
            static let dailyCard = "daily_card"
            static let birthCard = "birth_card"
            static let yearlyCard = "yearly_card"
            static let shareButton = "share_button"
            static let settingsButton = "settings_button"
            static let backButton = "back_button"
            static let closeButton = "close_button"
        }
        
        struct Contrast {
            static let minimumNormalText: Double = 4.5
            static let minimumLargeText: Double = 3.0
        }
    }
    
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
