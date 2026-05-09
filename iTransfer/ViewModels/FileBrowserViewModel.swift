import Foundation
import Combine

@MainActor
final class FileBrowserViewModel: ObservableObject {
    @Published var currentPath = "/"
    @Published var files: [FileItem] = []
    @Published var searchQuery = ""
    @Published var isSearching = false
    @Published var searchResults: [FileItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab: FileBrowserTab = .browse
    @Published var pathHistory: [String] = []

    enum FileBrowserTab: String, CaseIterable {
        case favorites = "收藏"
        case recent = "最近"
        case browse = "浏览"
        case more = "更多"
    }

    private let fileManager = FileManagerService.shared

    var displayPath: String {
        "文件系统: \(currentPath)"
    }

    var backButtonVisible: Bool {
        currentPath != "/"
    }

    func loadFiles() async {
        isLoading = true
        defer { isLoading = false }
        do {
            files = try fileManager.listDirectory(at: currentPath)
        } catch {
            errorMessage = error.localizedDescription
            files = []
        }
    }

    func navigateTo(path: String) {
        pathHistory.append(currentPath)
        currentPath = path
        Task { await loadFiles() }
    }

    func navigateBack() {
        guard let previous = pathHistory.popLast() else { return }
        currentPath = previous
        Task { await loadFiles() }
    }

    func navigateUp() {
        if currentPath == "/" { return }
        pathHistory.append(currentPath)
        let url = URL(fileURLWithPath: currentPath)
        currentPath = url.deletingLastPathComponent().path
        if currentPath.isEmpty { currentPath = "/" }
        Task { await loadFiles() }
    }

    func performSearch() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        isSearching = true
        searchResults = fileManager.searchFiles(query: searchQuery, in: currentPath)
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        isSearching = false
    }

    func deleteItem(_ item: FileItem) {
        do {
            try fileManager.deleteItem(at: item.path)
            Task { await loadFiles() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
