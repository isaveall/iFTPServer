import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var appSettings = AppSettings.shared

    // Account management
    @Published var accounts: [Account] = []
    @Published var whitelistIPs: [String] = []
    @Published var blacklistIPs: [String] = []

    private let accountsKey = "settings_accounts"
    private let whitelistKey = "settings_whitelist"
    private let blacklistKey = "settings_blacklist"

    init() {
        loadAccounts()
        loadIPLists()
    }

    var accountSummary: String {
        if accounts.isEmpty { return "匿名(只读)" }
        return "\(accounts.count)个账号"
    }

    var whitelistSummary: String {
        whitelistIPs.isEmpty ? "未开启" : "\(whitelistIPs.count)个IP"
    }

    var blacklistSummary: String {
        blacklistIPs.isEmpty ? "未开启" : "\(blacklistIPs.count)个IP"
    }

    func addAccount(_ account: Account) {
        accounts.append(account)
        saveAccounts()
    }

    func removeAccount(at index: Int) {
        accounts.remove(at: index)
        saveAccounts()
    }

    func addWhitelistIP(_ ip: String) {
        whitelistIPs.append(ip)
        saveIPLists()
    }

    func removeWhitelistIP(at index: Int) {
        whitelistIPs.remove(at: index)
        saveIPLists()
    }

    func addBlacklistIP(_ ip: String) {
        blacklistIPs.append(ip)
        saveIPLists()
    }

    func removeBlacklistIP(at index: Int) {
        blacklistIPs.remove(at: index)
        saveIPLists()
    }

    func toggleFileSharing() { appSettings.fileSharingEnabled.toggle() }
    func toggleNotifications() { appSettings.notificationsEnabled.toggle() }
    func toggleBackgroundRunning() { appSettings.backgroundRunningEnabled.toggle() }
    func toggleAutoStart() { appSettings.autoStartOnBoot.toggle() }

    private func saveAccounts() {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        UserDefaults.standard.set(data, forKey: accountsKey)
    }

    private func loadAccounts() {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let saved = try? JSONDecoder().decode([Account].self, from: data)
        else { return }
        accounts = saved
    }

    private func saveIPLists() {
        UserDefaults.standard.set(whitelistIPs, forKey: whitelistKey)
        UserDefaults.standard.set(blacklistIPs, forKey: blacklistKey)
    }

    private func loadIPLists() {
        whitelistIPs = UserDefaults.standard.stringArray(forKey: whitelistKey) ?? []
        blacklistIPs = UserDefaults.standard.stringArray(forKey: blacklistKey) ?? []
    }
}
