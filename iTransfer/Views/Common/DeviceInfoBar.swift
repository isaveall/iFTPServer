import SwiftUI

struct DeviceInfoBar: View {
    private let deviceInfo = DeviceInfoService.shared
    @State private var storageUsed = ""
    @State private var storageTotal = ""

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "iphone.gen3")
                    .font(.title3)
                    .foregroundColor(.blue)
                Text(deviceInfo.deviceName)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                ConnectionStatusIndicator()
            }

            HStack(spacing: 6) {
                Text(deviceInfo.deviceModel)
                Text("|")
                Text("iOS \(deviceInfo.iosVersion)")
                Text("|")
                Text("\(storageUsed)/\(storageTotal)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            storageUsed = deviceInfo.storageUsed
            storageTotal = deviceInfo.storageTotal
        }
    }
}

struct ConnectionStatusIndicator: View {
    @ObservedObject private var httpServer = HTTPServerService.shared
    @ObservedObject private var ftpServer = FTPServerService.shared

    private var isRunning: Bool {
        httpServer.isRunning || ftpServer.isRunning
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isRunning ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text(isRunning ? "已连接" : "未连接")
                .font(.caption2)
                .foregroundColor(isRunning ? .green : .secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color(.systemBackground)))
    }
}
