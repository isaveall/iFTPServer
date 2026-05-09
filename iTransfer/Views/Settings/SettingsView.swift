import SwiftUI

struct SettingsView: View {
    @StateObject private var serverVM = ServerViewModel()
    @StateObject private var settingsVM = SettingsViewModel()
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 无线共享
                wirelessSharingSection

                // MARK: - 传输
                transferSection

                // MARK: - 功能
                featuresSection

                // MARK: - 安全
                securitySection

                // MARK: - 关于
                aboutSection

                // MARK: - 恢复默认
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("恢复默认设置")
                                .font(.system(size: 16))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .alert("恢复默认设置", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("确认", role: .destructive) {
                    serverVM.resetToDefaults()
                }
            } message: {
                Text("此操作将重置所有设置，包括服务器配置、端口、账号信息等。此操作不可撤销。")
            }
        }
    }

    // MARK: - 无线共享

    private var wirelessSharingSection: some View {
        Section {
            // Server URL display
            if serverVM.isRunning {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(.green)
                        Text("无线共享")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { serverVM.isRunning },
                            set: { _ in serverVM.toggleRunning() }
                        ))
                        .labelsHidden()
                    }

                    HStack {
                        Text(serverVM.connectionURL)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button {
                            UIPasteboard.general.string = serverVM.connectionURL
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                }
            } else {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundColor(.secondary)
                    Text("无线共享")
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { serverVM.isRunning },
                        set: { _ in serverVM.toggleRunning() }
                    ))
                    .labelsHidden()
                }
            }

            // WiFi network info
            SettingsNavigationRow(
                title: "WiFi",
                value: serverVM.localIP
            )

            // HTTP toggle
            SettingsToggleRow("HTTP", isOn: $serverVM.config.httpEnabled)
                .onChange(of: serverVM.config.httpEnabled) { _, _ in serverVM.toggleHTTP() }

            // FTP toggle
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("FTP")
                        .font(.system(size: 16))
                    Text("端口: \(serverVM.config.port)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: $serverVM.config.ftpEnabled)
                    .labelsHidden()
                    .onChange(of: serverVM.config.ftpEnabled) { _, _ in serverVM.toggleFTP() }
            }

            // Server status
            if serverVM.isRunning {
                HStack {
                    Text("启动")
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("正在运行")
                            .foregroundColor(.green)
                    }
                    .font(.system(size: 14))
                }
            }

            // Auto stop
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("自动停止")
                        .font(.system(size: 16))
                    if serverVM.config.autoStopEnabled {
                        Text("\(serverVM.config.autoStopMinutes)分钟")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Toggle("", isOn: $serverVM.config.autoStopEnabled)
                    .labelsHidden()
                    .onChange(of: serverVM.config.autoStopEnabled) { _, _ in serverVM.toggleAutoStop() }
            }

        } header: {
            SettingsSectionHeader("无线共享")
        }
    }

    // MARK: - 传输

    private var transferSection: some View {
        Section {
            HStack {
                Text("端口")
                    .font(.system(size: 16))
                Spacer()
                TextField("端口", value: $serverVM.config.port, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(width: 80)
            }

            SettingsNavigationRow(title: "编码", value: serverVM.config.encoding)

            SettingsToggleRow("强制UTF-8", isOn: $serverVM.config.forceUTF8)
                .onChange(of: serverVM.config.forceUTF8) { _, _ in serverVM.toggleForceUTF8() }

        } header: {
            SettingsSectionHeader("传输")
        }
    }

    // MARK: - 功能

    private var featuresSection: some View {
        Section {
            SettingsToggleRow("文件共享", subtitle: "允许通过HTTP/FTP访问文件",
                              isOn: $settingsVM.appSettings.fileSharingEnabled)
                .onChange(of: settingsVM.appSettings.fileSharingEnabled) { _, _ in settingsVM.toggleFileSharing() }

            SettingsToggleRow("通知", subtitle: "接收传输完成通知",
                              isOn: $settingsVM.appSettings.notificationsEnabled)
                .onChange(of: settingsVM.appSettings.notificationsEnabled) { _, _ in settingsVM.toggleNotifications() }

            SettingsToggleRow("后台运行", subtitle: "允许在后台继续传输",
                              isOn: $settingsVM.appSettings.backgroundRunningEnabled)
                .onChange(of: settingsVM.appSettings.backgroundRunningEnabled) { _, _ in settingsVM.toggleBackgroundRunning() }

            SettingsToggleRow("开机自启", subtitle: "系统启动时自动运行服务",
                              isOn: $settingsVM.appSettings.autoStartOnBoot)
                .onChange(of: settingsVM.appSettings.autoStartOnBoot) { _, _ in settingsVM.toggleAutoStart() }

        } header: {
            SettingsSectionHeader("功能")
        }
    }

    // MARK: - 安全

    private var securitySection: some View {
        Section {
            SettingsNavigationRow(
                title: "账号设置",
                value: settingsVM.accountSummary
            ) { /* navigate to account settings */ }

            SettingsNavigationRow(
                title: "白名单",
                value: settingsVM.whitelistSummary
            ) { /* navigate to whitelist */ }

            SettingsNavigationRow(
                title: "黑名单",
                value: settingsVM.blacklistSummary
            ) { /* navigate to blacklist */ }

        } header: {
            SettingsSectionHeader("安全")
        }
    }

    // MARK: - 关于

    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                HStack {
                    Text("关于")
                        .font(.system(size: 16))
                    Spacer()
                    Text("v1.0.0")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
            }

        } header: {
            SettingsSectionHeader("关于")
        }
    }
}
