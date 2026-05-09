import Foundation
import Network

final class FTPServerService: ObservableObject, @unchecked Sendable {
    static let shared = FTPServerService()

    @Published var isRunning = false
    @Published var port: UInt16 = 2121
    @Published var connectedClients: Int = 0

    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let queue = DispatchQueue(label: "com.itransfer.ftp-server")

    private init() {}

    func start(port: UInt16) {
        guard !isRunning else { return }
        self.port = port

        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true

        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            print("FTP Server: invalid port")
            return
        }
        listener = try? NWListener(using: params, on: nwPort)

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready: self?.isRunning = true
                case .failed, .cancelled: self?.isRunning = false
                default: break
                }
            }
        }

        listener?.start(queue: queue)
    }

    func stop() {
        listener?.cancel()
        connections.forEach { $0.cancel() }
        connections.removeAll()
        isRunning = false
        connectedClients = 0
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        connections.append(connection)
        DispatchQueue.main.async { self.connectedClients = self.connections.count }

        send(connection, "220 iTransfer FTP Server Ready\r\n")
        receiveCommand(on: connection, currentDir: "/")
    }

    private func receiveCommand(on connection: NWConnection, currentDir: String) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, isComplete, error in
            guard let self, let data, !isComplete, error == nil else {
                connection.cancel()
                return
            }

            guard let command = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() else {
                connection.cancel()
                return
            }

            let parts = command.components(separatedBy: " ")
            let cmd = parts.first ?? ""

            switch cmd {
            case "USER":
                self.send(connection, "331 Anonymous access allowed, send identity as password.\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "PASS":
                self.send(connection, "230 Anonymous user logged in.\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "SYST":
                self.send(connection, "215 UNIX Type: L8\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "FEAT":
                self.send(connection, "211-Features:\r\n UTF8\r\n211 End\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "OPTS":
                self.send(connection, "200 UTF8 mode enabled.\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "PWD":
                self.send(connection, "257 \"\(currentDir)\" is current directory.\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "CWD":
                let path = parts.dropFirst().joined(separator: " ")
                let newDir = self.resolvePath(path, currentDir: currentDir)
                self.send(connection, "250 CWD successful. \"\(newDir)\" is current directory.\r\n")
                self.receiveCommand(on: connection, currentDir: newDir)

            case "TYPE":
                self.send(connection, "200 Switching to Binary mode.\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "PORT":
                self.send(connection, "200 PORT command successful.\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "PASV":
                self.send(connection, "227 Entering Passive Mode (127,0,0,1,8,73)\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "LIST", "NLST":
                self.handleList(connection, currentDir: currentDir)
                self.receiveCommand(on: connection, currentDir: currentDir)

            case "QUIT":
                self.send(connection, "221 Goodbye.\r\n")
                connection.cancel()
                DispatchQueue.main.async {
                    self.connections.removeAll { $0 === connection }
                    self.connectedClients = self.connections.count
                }

            default:
                self.send(connection, "500 Unknown command.\r\n")
                self.receiveCommand(on: connection, currentDir: currentDir)
            }
        }
    }

    private func handleList(_ connection: NWConnection, currentDir: String) {
        let fm = FileManagerService.shared
        var listing = ""
        do {
            let items = try fm.listDirectory(at: currentDir)
            for item in items {
                let perm = item.isDirectory ? "drwxr-xr-x" : "-rw-r--r--"
                let date = ISO8601DateFormatter().string(from: item.modificationDate)
                listing += "\(perm) 1 owner group \(item.size) \(date) \(item.name)\r\n"
            }
        } catch {
            listing = ""
        }
        self.send(connection, "150 Opening data connection.\r\n")
        self.send(connection, listing)
        self.send(connection, "226 Transfer complete.\r\n")
    }

    private func resolvePath(_ path: String, currentDir: String) -> String {
        if path.hasPrefix("/") { return path }
        if path == ".." {
            let parts = currentDir.components(separatedBy: "/").filter { !$0.isEmpty }
            if parts.isEmpty { return "/" }
            return "/" + parts.dropLast().joined(separator: "/")
        }
        if currentDir == "/" { return "/\(path)" }
        return "\(currentDir)/\(path)"
    }

    private func send(_ connection: NWConnection, _ message: String) {
        connection.send(content: message.data(using: .utf8), completion: .contentProcessed { _ in })
    }
}
