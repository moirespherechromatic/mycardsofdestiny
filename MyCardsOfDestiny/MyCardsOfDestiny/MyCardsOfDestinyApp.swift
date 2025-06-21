import SwiftUI

@main
struct CardsOfDestinyApp: App {
    @State private var showSplash = true
    
    init() {
        setupGlobalAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Global background color
                Color(red: 0.86, green: 0.77, blue: 0.57)
                    .ignoresSafeArea(.all)
                
                if showSplash {
                    VintageSplashView(onStart: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showSplash = false
                        }
                    })
                    .preferredColorScheme(.light)
                } else {
                    HomeView()
                        .preferredColorScheme(.light)
                        .transition(.opacity)
                }
            }
        }
    }
    
    private func setupGlobalAppearance() {
        // Global navigation bar styling
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 0.86, green: 0.77, blue: 0.57, alpha: 1.0)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Apothicaire Light Cd", size: 20) ?? UIFont.systemFont(ofSize: 20)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Apothicaire Light Cd", size: 34) ?? UIFont.systemFont(ofSize: 34)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // Global tint color
        UIView.appearance().tintColor = UIColor.black
        
        // Tab bar styling (if you add tabs later)
        UITabBar.appearance().backgroundColor = UIColor(red: 0.86, green: 0.77, blue: 0.57, alpha: 1.0)
        UITabBar.appearance().barTintColor = UIColor(red: 0.86, green: 0.77, blue: 0.57, alpha: 1.0)
        
        // Table view styling for any lists
        UITableView.appearance().backgroundColor = UIColor(red: 0.86, green: 0.77, blue: 0.57, alpha: 1.0)
        UITableViewCell.appearance().backgroundColor = UIColor(red: 0.86, green: 0.77, blue: 0.57, alpha: 1.0)
        
        // Scroll view styling
        UIScrollView.appearance().backgroundColor = UIColor(red: 0.86, green: 0.77, blue: 0.57, alpha: 1.0)
    }
}
