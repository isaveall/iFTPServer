import SwiftUI

@main
struct iTransferApp: App {
    @StateObject private var serverVM = ServerViewModel()

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(serverVM)
                .onAppear {
                    // Apply global appearance
                    configureAppearance()
                }
                .onChange(of: scenePhase) { _, phase in
                    switch phase {
                    case .background:
                        // Save state when going to background
                        break
                    case .active:
                        // Refresh network info when becoming active
                        serverVM.refreshNetworkInfo()
                    default:
                        break
                    }
                }
        }
    }

    private func configureAppearance() {
        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Table views
        UITableView.appearance().backgroundColor = .systemGroupedBackground
    }
}
