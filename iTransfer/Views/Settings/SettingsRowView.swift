import SwiftUI

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    init(_ title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct SettingsNavigationRow: View {
    let title: String
    let value: String
    var action: (() -> Void)? = nil

    var body: some View {
        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink { EmptyView() } label: {
                content
            }
        }
    }

    private var content: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SettingsSectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.footnote)
            .foregroundColor(.secondary)
            .textCase(nil)
    }
}
