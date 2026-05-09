import SwiftUI

struct FileRowView: View {
    let item: FileItem
    var onTap: () -> Void
    var onDelete: (() -> Void)?

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: item.iconName)
                    .font(.title3)
                    .foregroundColor(item.isDirectory ? .blue : iconColor)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.isDirectory ? Color.blue.opacity(0.1) : iconBgColor)
                    )

                // Name and metadata
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        if !item.isDirectory {
                            Text(item.formattedSize)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(item.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if !item.isDirectory {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            if let onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("删除", systemImage: "trash")
                }
            }
        }
    }

    private var iconColor: Color {
        switch item.iconColor {
        case "photo": return .orange
        case "video": return .purple
        case "music": return .pink
        default: return .gray
        }
    }

    private var iconBgColor: Color {
        switch item.iconColor {
        case "photo": return Color.orange.opacity(0.1)
        case "video": return Color.purple.opacity(0.1)
        case "music": return Color.pink.opacity(0.1)
        default: return Color(.systemGray6)
        }
    }
}
