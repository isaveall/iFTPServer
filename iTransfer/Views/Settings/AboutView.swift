import SwiftUI

struct AboutView: View {
    @State private var showPrivacy = false
    @State private var showLicense = false

    var body: some View {
        List {
            // App icon and version
            Section {
                VStack(spacing: 12) {
                    // App icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "arrow.triangle.swap")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 4) {
                        Text("iTransfer")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("v1.0.0")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .listRowBackground(Color.clear)

            // Links
            Section {
                aboutLink("意见与反馈", icon: "envelope.fill", color: .blue) {
                    openMail()
                }

                aboutLink("评分与推荐", icon: "star.fill", color: .yellow) {
                    openAppStore()
                }

                aboutLink("联系我们", icon: "person.2.fill", color: .green) {
                    openMail()
                }

                aboutLink("开源许可", icon: "doc.text.fill", color: .gray) {
                    showLicense = true
                }

                aboutLink("隐私政策与用户协议", icon: "lock.shield.fill", color: .blue) {
                    showPrivacy = true
                }
            }

            // Copyright
            Section {
                VStack(spacing: 4) {
                    Text("Copyright © \(Calendar.current.component(.year, from: Date())) iTransfer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("All Rights Reserved.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showPrivacy) {
            NavigationStack {
                ScrollView {
                    Text(privacyPolicyText)
                        .font(.body)
                        .padding()
                }
                .navigationTitle("隐私政策与用户协议")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("关闭") { showPrivacy = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showLicense) {
            NavigationStack {
                ScrollView {
                    Text(openSourceLicenseText)
                        .font(.body)
                        .padding()
                }
                .navigationTitle("开源许可")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("关闭") { showLicense = false }
                    }
                }
            }
        }
    }

    private func aboutLink(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(color)
                    )

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private func openMail() {
        if let url = URL(string: "mailto:support@itransfer.app") {
            UIApplication.shared.open(url)
        }
    }

    private func openAppStore() {
        // Replace with actual App Store ID
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1234567890") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Legal Texts

private let privacyPolicyText = """
隐私政策与用户协议

最后更新日期：2026年5月

1. 信息收集
iTransfer 不会收集、存储或传输您的个人数据到外部服务器。所有文件传输仅在您的本地网络内进行。

2. 本地网络使用
iTransfer 使用本地网络创建 HTTP/FTP 服务器，以便其他设备可以访问您选择的文件。我们不会将任何文件或数据传输到互联网。

3. 数据存储
所有应用设置和配置仅存储在您的设备本地，不会上传到任何云服务。

4. 用户协议
使用本应用即表示您同意：
- 不会使用本应用传播非法内容
- 不会使用本应用侵犯他人知识产权
- 理解文件共享的安全性由用户自行负责
- 在公共WiFi环境下使用时自行承担风险

5. 免责声明
本应用按"现状"提供，开发者不对因使用本应用而导致的任何数据丢失或损害承担责任。

6. 联系我们
如有任何问题，请发送邮件至 support@itransfer.app
"""

private let openSourceLicenseText = """
开源许可

iTransfer 使用了以下开源组件：

---

MIT License

Copyright (c) 2026 iTransfer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
