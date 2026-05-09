import Foundation

final class DeviceInfoService {
    nonisolated(unsafe) static let shared = DeviceInfoService()

    private init() {}

    var deviceModel: String {
        var info = utsname()
        uname(&info)
        let machine = withUnsafePointer(to: &info.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
                String(cString: $0)
            }
        }
        return mapToModel(machine)
    }

    var iosVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion)"
    }

    var storageUsed: String {
        let info = FileManagerService.shared.storageInfo
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: info.used)
    }

    var storageTotal: String {
        let info = FileManagerService.shared.storageInfo
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: info.total)
    }

    var deviceName: String {
        ProcessInfo.processInfo.hostName
    }

    var wifiIPAddress: String? {
        var addr: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }
        var ptr = first
        while true {
            let name = String(cString: ptr.pointee.ifa_name)
            let flags = Int32(ptr.pointee.ifa_flags)
            if name == "en0" && (flags & IFF_UP) != 0 && (flags & IFF_RUNNING) != 0 {
                let addr4 = ptr.pointee.ifa_addr.pointee
                if addr4.sa_family == UInt8(AF_INET) {
                    var buffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(
                        ptr.pointee.ifa_addr,
                        socklen_t(addr4.sa_len),
                        &buffer,
                        socklen_t(buffer.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    )
                    addr = String(cString: buffer)
                    break
                }
            }
            guard let next = ptr.pointee.ifa_next else { break }
            ptr = next
        }
        return addr
    }

    var wifiSSID: String? {
        #if !targetEnvironment(simulator)
        // Requires location + NEHotspotHelper entitlement for real use
        return nil
        #else
        return "模拟器WiFi"
        #endif
    }

    private func mapToModel(_ machine: String) -> String {
        let models: [String: String] = [
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
        ]
        return models[machine] ?? machine
    }
}
