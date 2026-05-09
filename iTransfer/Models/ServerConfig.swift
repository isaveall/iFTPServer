import Foundation

struct ServerConfig: Codable {
    var httpEnabled: Bool = true
    var ftpEnabled: Bool = true
    var port: UInt16 = 2121
    var isRunning: Bool = false
    var autoStopEnabled: Bool = true
    var autoStopMinutes: Int = 30
    var encoding: String = "UTF-8"
    var forceUTF8: Bool = true
    var allowAnonymousReadOnly = true
    var whitelistEnabled: Bool = false
    var whitelistIPs: [String] = []
    var blacklistEnabled: Bool = false
    var blacklistIPs: [String] = []
}

struct Account: Identifiable, Codable {
    let id = UUID()
    var username: String
    var password: String
    var isReadOnly: Bool
}
