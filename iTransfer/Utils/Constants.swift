import Foundation

enum Constants {
    static let appName = "iTransfer"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"

    static let defaultPort: UInt16 = 2121
    static let defaultEncoding = "UTF-8"
    static let defaultAutoStopMinutes = 30

    static let supportEmail = "support@itransfer.app"
    static let appStoreURL = "itms-apps://itunes.apple.com/app/id1234567890"

    static let maxConnectionCount = 10
    static let maxFileSizeForPreview: Int64 = 50 * 1024 * 1024 // 50MB

    static let userDefaultsKey = (
        serverConfig: "server_config",
        accounts: "settings_accounts",
        whitelist: "settings_whitelist",
        blacklist: "settings_blacklist"
    )
}
