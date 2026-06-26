# iTransfer

[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/swift-6.0-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

iTransfer 是一款 iOS 无线文件传输应用，通过在 iPhone 上启动内嵌的 HTTP/FTP 服务器，让同一局域网内的其他设备通过浏览器或 FTP 客户端直接访问和管理手机文件。

<p align="center">
  <img src="https://github.com/isaveall/iFTPServer/blob/main/screenshot/文件列表界面.jpg" width="30%" alt="文件列表" />
  <img src="https://github.com/isaveall/iFTPServer/blob/main/screenshot/About界面.jpg" width="30%" alt="关于" />
  <img src="https://github.com/isaveall/iFTPServer/blob/main/screenshot/Setting界面.jpg" width="30%" alt="设置" />
</p>

## ✨ 功能

- **文件浏览** — 文件系统浏览、搜索、路径导航
- **HTTP 服务器** — 内置 HTTP 服务，浏览器直接访问并下载文件（含精美的移动端目录列表页）
- **FTP 服务器** — 支持 FTP 协议，可使用任意 FTP 客户端连接
- **无线传输** — 无需数据线，局域网内跨设备无线传输文件
- **二维码分享** — 一键生成连接二维码，扫码即连
- **安全配置** — 匿名只读、账号管理、IP 黑白名单
- **灵活设置** — 端口自定义、编码设置、自动停止、后台运行

## 📋 技术栈

| 模块 | 方案 |
|------|------|
| UI | SwiftUI |
| 架构 | MVVM + Singleton Services |
| HTTP 服务 | Network.framework (NWListener) |
| FTP 服务 | Network.framework (NWListener) |
| 文件管理 | FileManager |
| 最低系统 | iOS 17.0 |
| 依赖 | 无第三方依赖 |

## 🚀 快速开始

### 环境要求

- macOS 15.0+
- Xcode 26.0+
- iOS 17.0+ (设备或模拟器)

### 构建运行

```bash
# 1. 安装 XcodeGen
brew install xcodegen

# 2. 生成 Xcode 项目
xcodegen generate

# 3. 打开项目
open iTransfer.xcodeproj

# 4. 在 Xcode 中按 Cmd+R 运行
```

选择 iPhone 模拟器或真机，点击运行即可。

## 📁 项目结构

```
iTransfer/
├── project.yml                        # XcodeGen 配置
├── iTransfer/
│   ├── App/
│   │   └── iTransferApp.swift         # 应用入口
│   ├── Models/
│   │   ├── FileItem.swift             # 文件/目录模型
│   │   ├── ServerConfig.swift         # 服务器配置模型
│   │   └── AppSettings.swift          # 用户偏好设置
│   ├── ViewModels/
│   │   ├── FileBrowserViewModel.swift # 文件浏览逻辑
│   │   ├── ServerViewModel.swift      # 服务器启停控制
│   │   └── SettingsViewModel.swift    # 账号/黑白名单管理
│   ├── Views/
│   │   ├── MainTabView.swift          # 三 Tab 容器
│   │   ├── Common/DeviceInfoBar.swift # 设备信息栏
│   │   ├── FileBrowser/               # 文件浏览页面组件
│   │   ├── Transfer/TransferView.swift # 传输页面
│   │   └── Settings/                  # 设置 & 关于页面
│   ├── Services/
│   │   ├── FileManagerService.swift   # 文件系统操作
│   │   ├── HTTPServerService.swift    # HTTP 服务器
│   │   ├── FTPServerService.swift     # FTP 服务器
│   │   └── DeviceInfoService.swift    # 设备信息
│   └── Utils/
│       ├── Extensions.swift           # SwiftUI 扩展
│       └── Constants.swift            # 全局常量
```

## 📖 使用指南

### 启动文件共享

1. 打开应用，切换到 **设置** 标签页
2. 点击 **无线共享** 开关，启动服务器
3. 在同一 Wi-Fi 下的任意设备浏览器中输入显示的 URL（如 `http://192.168.1.100:2121`）
4. 即可浏览和下载手机文件

### 自定义配置

- **端口** — 在设置中修改 HTTP/FTP 服务端口（默认 2121）
- **自动停止** — 可设置一段时间后自动关闭服务，节省电量
- **安全** — 可配置账号密码、IP 白名单/黑名单

## 📄 License

MIT License. 详见 [LICENSE](LICENSE) 文件。

---

*Made with ❤️ for iOS*
