import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .files

    enum Tab: String, CaseIterable {
        case files = "文件"
        case transfer = "传输"
        case settings = "设置"

        var icon: String {
            switch self {
            case .files: return "folder.fill"
            case .transfer: return "arrow.left.arrow.right"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            FileBrowserView()
                .tabItem {
                    Label(Tab.files.rawValue, systemImage: Tab.files.icon)
                }
                .tag(Tab.files)

            TransferView()
                .tabItem {
                    Label(Tab.transfer.rawValue, systemImage: Tab.transfer.icon)
                }
                .tag(Tab.transfer)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(.blue)
    }
}
