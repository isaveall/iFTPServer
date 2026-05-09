import Foundation
import Network

final class HTTPServerService: ObservableObject, @unchecked Sendable {
    static let shared = HTTPServerService()

    @Published var isRunning = false
    @Published var port: UInt16 = 2121
    @Published var connectedClients: Int = 0

    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let queue = DispatchQueue(label: "com.itransfer.http-server")

    private init() {}

    func start(port: UInt16) {
        guard !isRunning else { return }
        self.port = port

        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true

        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            print("HTTP Server: invalid port")
            return
        }
        listener = try? NWListener(using: params, on: nwPort)

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isRunning = true
                case .failed, .cancelled:
                    self?.isRunning = false
                default:
                    break
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

        receiveHTTPRequest(on: connection)
    }

    private func receiveHTTPRequest(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self, let data, !isComplete, error == nil else {
                connection.cancel()
                return
            }

            if let request = String(data: data, encoding: .utf8) {
                let response = self.buildHTTPResponse(for: request)
                connection.send(content: response.data(using: .utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                    DispatchQueue.main.async {
                        self.connections.removeAll { $0 === connection }
                        self.connectedClients = self.connections.count
                    }
                })
            } else {
                connection.cancel()
            }
        }
    }

    private func buildHTTPResponse(for request: String) -> String {
        let lines = request.components(separatedBy: "\r\n")
        guard let firstLine = lines.first else { return httpError(400, "Bad Request") }

        let parts = firstLine.components(separatedBy: " ")
        guard parts.count >= 2 else { return httpError(400, "Bad Request") }

        let method = parts[0]
        var rawPath = parts[1]

        // Decode percent encoding
        rawPath = rawPath.removingPercentEncoding ?? rawPath

        switch method {
        case "GET":
            return serveFile(path: rawPath)
        case "HEAD":
            return serveFile(path: rawPath, headOnly: true)
        default:
            return httpError(405, "Method Not Allowed")
        }
    }

    private func serveFile(path: String, headOnly: Bool = false) -> String {
        let fm = FileManagerService.shared
        let fileURL = fm.contentURL(for: path)

        // Directory listing
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDir) else {
            return httpError(404, "Not Found")
        }

        if isDir.boolValue {
            return buildDirectoryListing(at: fileURL, relativePath: path)
        }

        // Serve file
        guard let data = try? Data(contentsOf: fileURL) else {
            return httpError(500, "Internal Server Error")
        }

        let mime = mimeType(for: fileURL.pathExtension)
        let body = headOnly ? Data() : data
        return httpResponse(200, mime: mime, body: body)
    }

    private func buildDirectoryListing(at url: URL, relativePath: String) -> String {
        let fm = FileManagerService.shared
        let items: [FileItem]
        do {
            items = try fm.listDirectory(at: relativePath)
        } catch {
            items = []
        }

        var html = """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
        <title>iTransfer - \(relativePath)</title>
        <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;background:#f5f5f7;color:#1d1d1f;padding:16px;}
        .header{background:#fff;border-radius:16px;padding:16px;margin-bottom:16px;box-shadow:0 1px 3px rgba(0,0,0,0.08);}
        .header h1{font-size:20px;font-weight:600;color:#007aff;}
        .header .path{font-size:13px;color:#86868b;font-family:monospace;margin-top:4px;word-break:break-all;}
        .list{background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.08);}
        .item{display:flex;align-items:center;padding:12px 16px;border-bottom:1px solid #f0f0f0;text-decoration:none;color:#1d1d1f;}
        .item:last-child{border-bottom:none;}
        .item:hover{background:#f0f0f5;}
        .icon{width:32px;height:32px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:18px;margin-right:12px;flex-shrink:0;}
        .folder-icon{background:#e8f0fe;color:#007aff;}
        .file-icon{background:#f0f0f5;color:#86868b;}
        .name{flex:1;font-size:15px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
        .meta{font-size:12px;color:#aeaeb2;margin-left:12px;flex-shrink:0;}
        .up{font-weight:500;}
        .empty{text-align:center;padding:40px 16px;color:#aeaeb2;}
        </style></head>
        <body>
        <div class="header">
        <h1>iTransfer</h1>
        <div class="path">\(relativePath)</div>
        </div>
        <div class="list">
        """

        // Parent directory link
        if relativePath != "/" {
            let parent = (relativePath as NSString).deletingLastPathComponent
            let parentDisplay = parent.isEmpty ? "/" : parent
            html += """
            <a class="item up" href="\(parentDisplay)">
            <div class="icon folder-icon">↑</div><div class="name">上级目录</div>
            </a>
            """
        }

        if items.isEmpty {
            html += "<div class=\"empty\">空目录</div>"
        } else {
            for item in items {
                let href = relativePath == "/" ? "/\(item.name)" : "\(relativePath)/\(item.name)"
                let encoded = href.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? href
                let icon = item.isDirectory ? "📁" : "📄"
                let iconClass = item.isDirectory ? "folder-icon" : "file-icon"
                html += """
                <a class="item" href="\(encoded)">
                <div class="icon \(iconClass)">\(icon)</div>
                <div class="name">\(item.name)</div>
                <div class="meta">\(item.isDirectory ? "" : item.formattedSize)</div>
                </a>
                """
            }
        }

        html += "</div></body></html>"
        return httpResponse(200, mime: "text/html; charset=utf-8", body: html.data(using: .utf8)!)
    }

    private func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html", "htm": return "text/html; charset=utf-8"
        case "css": return "text/css"
        case "js": return "application/javascript"
        case "json": return "application/json"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "svg": return "image/svg+xml"
        case "pdf": return "application/pdf"
        case "zip": return "application/zip"
        case "mp3": return "audio/mpeg"
        case "mp4": return "video/mp4"
        case "txt": return "text/plain"
        default: return "application/octet-stream"
        }
    }

    private func httpResponse(_ code: Int, mime: String, body: Data) -> String {
        let status = code == 200 ? "OK" : "Error"
        return """
        HTTP/1.1 \(code) \(status)\r
        Content-Type: \(mime)\r
        Content-Length: \(body.count)\r
        Connection: close\r
        \r
        """ + (String(data: body, encoding: .utf8) ?? "")
    }

    private func httpError(_ code: Int, _ message: String) -> String {
        let body = """
        <!DOCTYPE html><html><head><meta charset="UTF-8"></head>
        <body><h1>\(code) \(message)</h1><p>iTransfer</p></body></html>
        """
        return httpResponse(code, mime: "text/html; charset=utf-8", body: body.data(using: .utf8)!)
    }
}
