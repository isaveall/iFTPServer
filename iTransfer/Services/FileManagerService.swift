import Foundation

final class FileManagerService {
    nonisolated(unsafe) static let shared = FileManagerService()

    private let fileManager = FileManager.default
    private let documentRoot: URL

    private init() {
        documentRoot = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func listDirectory(at path: String) throws -> [FileItem] {
        let url: URL
        if path == "/" {
            url = documentRoot
        } else {
            let relative = path.hasPrefix("/") ? String(path.dropFirst()) : path
            url = documentRoot.appendingPathComponent(relative)
        }

        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [
            .isDirectoryKey, .fileSizeKey, .contentModificationDateKey
        ], options: .skipsHiddenFiles)

        return try contents.map { url in
            let resource = try url.resourceValues(forKeys: [
                .isDirectoryKey, .fileSizeKey, .contentModificationDateKey
            ])
            return FileItem(
                name: url.lastPathComponent,
                path: url.path,
                isDirectory: resource.isDirectory ?? false,
                size: Int64(resource.fileSize ?? 0),
                modificationDate: resource.contentModificationDate ?? Date(),
                extension: url.pathExtension
            )
        }.sorted { a, b in
            if a.isDirectory != b.isDirectory { return a.isDirectory }
            return a.name.localizedStandardCompare(b.name) == .orderedAscending
        }
    }

    func listRootDirectories() -> [FileItem] {
        var items: [FileItem] = []
        // Document root
        items.append(FileItem(
            name: "文稿",
            path: documentRoot.path,
            isDirectory: true,
            size: 0,
            modificationDate: Date(),
            extension: ""
        ))
        // App bundle (read-only browsing)
        if let bundleRoot = Bundle.main.resourceURL {
            items.append(FileItem(
                name: "应用资源",
                path: bundleRoot.path,
                isDirectory: true,
                size: 0,
                modificationDate: Date(),
                extension: ""
            ))
        }
        return items
    }

    func fileExists(at path: String) -> Bool {
        fileManager.fileExists(atPath: path)
    }

    func deleteItem(at path: String) throws {
        try fileManager.removeItem(atPath: path)
    }

    func createDirectory(at path: String, name: String) throws {
        let url = URL(fileURLWithPath: path).appendingPathComponent(name)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
    }

    func moveItem(fromPath source: String, toPath destination: String) throws {
        try fileManager.moveItem(atPath: source, toPath: destination)
    }

    func copyItem(fromPath source: String, toPath destination: String) throws {
        try fileManager.copyItem(atPath: source, toPath: destination)
    }

    func contentURL(for path: String) -> URL {
        if path.hasPrefix(documentRoot.path) {
            return URL(fileURLWithPath: path)
        }
        let relative = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return documentRoot.appendingPathComponent(relative)
    }

    func relativePath(from absolutePath: String) -> String {
        let root = documentRoot.path
        if absolutePath == root { return "/" }
        guard absolutePath.hasPrefix(root) else { return absolutePath }
        return String(absolutePath.dropFirst(root.count))
    }

    var rootURL: URL { documentRoot }

    var storageInfo: (used: Int64, total: Int64) {
        do {
            let values = try documentRoot.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey])
            let total = Int64(values.volumeTotalCapacity ?? 0)
            let available = Int64(values.volumeAvailableCapacityForImportantUsage ?? 0)
            return (total - available, total)
        } catch {
            return (0, 0)
        }
    }

    func searchFiles(query: String, in path: String) -> [FileItem] {
        var results: [FileItem] = []
        let url = path == "/" ? documentRoot : URL(fileURLWithPath: path)
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return results }

        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent.localizedCaseInsensitiveContains(query) {
                do {
                    let resource = try fileURL.resourceValues(forKeys: [
                        .isDirectoryKey, .fileSizeKey, .contentModificationDateKey
                    ])
                    results.append(FileItem(
                        name: fileURL.lastPathComponent,
                        path: fileURL.path,
                        isDirectory: resource.isDirectory ?? false,
                        size: Int64(resource.fileSize ?? 0),
                        modificationDate: resource.contentModificationDate ?? Date(),
                        extension: fileURL.pathExtension
                    ))
                } catch {}
            }
        }
        return results
    }
}
