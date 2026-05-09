import SwiftUI

struct TransferView: View {
    @StateObject private var serverVM = ServerViewModel()
    @State private var showQRCode = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Connection status card
                connectionStatusCard

                // Transfer info
                if serverVM.isRunning {
                    transferInfoSection
                }

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("传输")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showQRCode) {
                qrCodeSheet
            }
        }
    }

    // MARK: - Connection Status Card

    private var connectionStatusCard: some View {
        VStack(spacing: 20) {
            // Status indicator
            ZStack {
                Circle()
                    .stroke(
                        serverVM.isRunning ? Color.green.opacity(0.2) : Color.gray.opacity(0.2),
                        lineWidth: 8
                    )
                    .frame(width: 100, height: 100)

                if serverVM.isRunning {
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            Color.green,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                }

                VStack(spacing: 4) {
                    Image(systemName: serverVM.isRunning ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 28))
                        .foregroundColor(serverVM.isRunning ? .green : .secondary)
                    Text(serverVM.isRunning ? "运行中" : "已停止")
                        .font(.caption)
                        .foregroundColor(serverVM.isRunning ? .green : .secondary)
                }
            }

            // Server URL
            if serverVM.isRunning {
                VStack(spacing: 6) {
                    Text("在浏览器或FTP客户端中访问:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Text(serverVM.connectionURL)
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundColor(.primary)

                        Button {
                            UIPasteboard.general.string = serverVM.connectionURL
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
            }

            // Action buttons
            HStack(spacing: 16) {
                // Start/Stop button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        serverVM.toggleRunning()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: serverVM.isRunning ? "stop.fill" : "play.fill")
                        Text(serverVM.isRunning ? "停止服务" : "启动服务")
                            .fontWeight(.medium)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(serverVM.isRunning ? Color.red : Color.blue)
                    )
                }

                // QR Code
                if serverVM.isRunning {
                    Button {
                        showQRCode = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "qrcode")
                            Text("二维码")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                    }
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding(16)
    }

    // MARK: - Transfer Info

    private var transferInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("传输信息")
                .font(.footnote)
                .foregroundColor(.secondary)
                .textCase(nil)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                transferInfoRow(
                    icon: "server.rack",
                    title: "HTTP 服务",
                    value: serverVM.config.httpEnabled ? "启用" : "禁用",
                    color: serverVM.config.httpEnabled ? .green : .secondary
                )

                Divider().padding(.leading, 52)

                transferInfoRow(
                    icon: "arrow.left.arrow.right",
                    title: "FTP 服务",
                    value: serverVM.config.ftpEnabled ? "启用" : "禁用",
                    color: serverVM.config.ftpEnabled ? .green : .secondary
                )

                Divider().padding(.leading, 52)

                transferInfoRow(
                    icon: "number",
                    title: "端口",
                    value: "\(serverVM.config.port)",
                    color: .primary
                )

                Divider().padding(.leading, 52)

                transferInfoRow(
                    icon: "textformat",
                    title: "编码",
                    value: serverVM.config.encoding,
                    color: .primary
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }

    private func transferInfoRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - QR Code Sheet

    private var qrCodeSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // QR Code Image
                Group {
                    if let qrImage = generateQRCode(from: serverVM.connectionURL) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5))
                            .frame(width: 220, height: 220)
                            .overlay(Text("生成失败").foregroundColor(.secondary))
                    }
                }

                Text(serverVM.connectionURL)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("扫描二维码在浏览器中打开")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    if let qrImage = generateQRCode(from: serverVM.connectionURL) {
                        UIImageWriteToSavedPhotosAlbum(qrImage, nil, nil, nil)
                    }
                } label: {
                    Label("保存到相册", systemImage: "square.and.arrow.down")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal, 40)
            }
            .navigationTitle("分享二维码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("关闭") { showQRCode = false }
                }
            }
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }

        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
