import Foundation

@MainActor
final class ServerViewModel: ObservableObject {
    @Published var config = ServerConfig()
    @Published var wifiName = "WiFi"
    @Published var localIP = "未连接"
    @Published var connectionURL = ""

    private let httpServer = HTTPServerService.shared
    private let ftpServer = FTPServerService.shared
    private let deviceInfo = DeviceInfoService.shared

    private let configKey = "server_config"

    init() {
        loadConfig()
        refreshNetworkInfo()
    }

    var isRunning: Bool {
        httpServer.isRunning || ftpServer.isRunning
    }

    var statusText: String {
        if isRunning {
            if config.httpEnabled && config.httpEnabled { return "HTTP & FTP 正在运行" }
            if config.httpEnabled { return "HTTP 正在运行" }
            if config.ftpEnabled { return "FTP 正在运行" }
        }
        return "已停止"
    }

    func toggleHTTP() {
        config.httpEnabled.toggle()
        saveConfig()
        if isRunning { restartServers() }
    }

    func toggleFTP() {
        config.ftpEnabled.toggle()
        saveConfig()
        if isRunning { restartServers() }
    }

    func startServers() {
        if config.httpEnabled {
            httpServer.start(port: config.port)
        }
        if config.ftpEnabled {
            ftpServer.start(port: config.port)
        }
        config.isRunning = true
        saveConfig()

        if let ip = localIPURL {
            connectionURL = "http://\(ip):\(config.port)"
        }
    }

    func stopServers() {
        httpServer.stop()
        ftpServer.stop()
        config.isRunning = false
        saveConfig()
        connectionURL = ""
    }

    func toggleRunning() {
        if isRunning { stopServers() } else { startServers() }
    }

    func updatePort(_ newPort: UInt16) {
        config.port = newPort
        saveConfig()
        if isRunning { restartServers() }
    }

    func toggleAutoStop() {
        config.autoStopEnabled.toggle()
        saveConfig()
    }

    func setAutoStopMinutes(_ minutes: Int) {
        config.autoStopMinutes = minutes
        saveConfig()
    }

    func toggleForceUTF8() {
        config.forceUTF8.toggle()
        saveConfig()
    }

    func refreshNetworkInfo() {
        localIP = deviceInfo.wifiIPAddress ?? "无连接"
        if let ip = localIPURL {
            connectionURL = "http://\(ip):\(config.port)"
        }
    }

    var localIPURL: String? {
        deviceInfo.wifiIPAddress
    }

    func resetToDefaults() {
        config = ServerConfig()
        stopServers()
        saveConfig()
    }

    private func restartServers() {
        stopServers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startServers()
        }
    }

    private func saveConfig() {
        guard let data = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(data, forKey: configKey)
    }

    private func loadConfig() {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let saved = try? JSONDecoder().decode(ServerConfig.self, from: data)
        else { return }
        config = saved
    }
}
