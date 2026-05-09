import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64
    let modificationDate: Date
    let `extension`: String

    var isHidden: Bool { name.hasPrefix(".") }

    var formattedSize: String {
        if isDirectory { return "--" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: modificationDate)
    }

    var iconName: String {
        if isDirectory { return "folder.fill" }
        switch `extension`.lowercased() {
        case "jpg", "jpeg", "png", "gif", "heic", "webp":
            return "photo.fill"
        case "mp4", "mov", "avi", "mkv":
            return "play.rectangle.fill"
        case "mp3", "aac", "wav", "flac":
            return "music.note"
        case "pdf":
            return "doc.richtext.fill"
        case "zip", "rar", "7z", "tar", "gz":
            return "doc.zipper"
        case "swift", "h", "m", "c", "cpp", "py", "js", "go":
            return "chevron.left.forwardslash.chevron.right"
        default:
            return "doc.fill"
        }
    }

    var iconColor: String {
        if isDirectory { return "folder" }
        switch `extension`.lowercased() {
        case "jpg", "jpeg", "png", "gif", "heic", "webp": return "photo"
        case "mp4", "mov", "avi", "mkv": return "video"
        case "mp3", "aac", "wav", "flac": return "music"
        default: return "document"
        }
    }
}
