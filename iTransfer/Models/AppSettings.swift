import Foundation
import SwiftUI

final class AppSettings: ObservableObject {
    nonisolated(unsafe) static let shared = AppSettings()

    @Published var fileSharingEnabled: Bool {
        didSet { UserDefaults.standard.set(fileSharingEnabled, forKey: key_fileSharing) }
    }
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: key_notifications) }
    }
    @Published var backgroundRunningEnabled: Bool {
        didSet { UserDefaults.standard.set(backgroundRunningEnabled, forKey: key_background) }
    }
    @Published var autoStartOnBoot: Bool {
        didSet { UserDefaults.standard.set(autoStartOnBoot, forKey: key_autoStart) }
    }

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: key_fileSharing) == nil {
            defaults.set(true, forKey: key_fileSharing)
        }
        self.fileSharingEnabled = defaults.bool(forKey: key_fileSharing)
        self.notificationsEnabled = defaults.bool(forKey: key_notifications)
        self.backgroundRunningEnabled = defaults.bool(forKey: key_background)
        self.autoStartOnBoot = defaults.bool(forKey: key_autoStart)
    }
}

private let key_fileSharing = "app_settings_file_sharing"
private let key_notifications = "app_settings_notifications"
private let key_background = "app_settings_background"
private let key_autoStart = "app_settings_auto_start"
