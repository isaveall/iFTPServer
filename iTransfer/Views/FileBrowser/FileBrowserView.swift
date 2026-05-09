import SwiftUI

struct FileBrowserView: View {
    @StateObject private var viewModel = FileBrowserViewModel()
    @State private var showJoke = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Device info
                DeviceInfoBar()

                Divider()

                // Search bar
                FileSearchBar(
                    text: $viewModel.searchQuery,
                    onSubmit: { viewModel.performSearch() },
                    onClear: { viewModel.clearSearch() }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))

                // Joke cell
                if showJoke && !viewModel.isSearching {
                    JokeCell(onDismiss: { showJoke = false })
                }

                // Path bar
                if viewModel.isSearching {
                    searchResultsHeader
                } else {
                    pathNavigationBar
                }

                // Tab selector
                fileTabSelector

                // File list
                fileList
            }
            .background(Color(.systemGroupedBackground))
            .task { await viewModel.loadFiles() }
            .refreshable { await viewModel.loadFiles() }
        }
    }

    // MARK: - Path Navigation

    private var pathNavigationBar: some View {
        HStack(spacing: 4) {
            Button(action: { viewModel.navigateTo(path: "/") }) {
                Image(systemName: "house.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.blue)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 9))
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(pathComponents, id: \.self) { component in
                        if component != "/" {
                            Button(component) {
                                viewModel.navigateTo(path: pathUpTo(component))
                            }
                            .font(.system(size: 13))
                            .foregroundColor(.blue)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }

    private var pathComponents: [String] {
        guard viewModel.currentPath != "/" else { return ["/"] }
        let comps = viewModel.currentPath.components(separatedBy: "/").filter { !$0.isEmpty }
        return ["/"] + comps
    }

    private func pathUpTo(_ component: String) -> String {
        let comps = pathComponents
        guard let idx = comps.firstIndex(of: component) else { return "/" }
        if idx == 0 { return "/" }
        return "/" + comps[1...idx].joined(separator: "/")
    }

    // MARK: - Search Results

    private var searchResultsHeader: some View {
        HStack {
            Text("搜索结果: \(viewModel.searchResults.count) 项")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Button("取消") { viewModel.clearSearch() }
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Tab Selector

    private var fileTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(FileBrowserViewModel.FileBrowserTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: viewModel.selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(viewModel.selectedTab == tab ? .blue : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                let tabWidth = geo.size.width / CGFloat(FileBrowserViewModel.FileBrowserTab.allCases.count)
                let selectedIndex = CGFloat(FileBrowserViewModel.FileBrowserTab.allCases.firstIndex(of: viewModel.selectedTab) ?? 0)
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: tabWidth - 20, height: 2)
                    .offset(x: tabWidth * selectedIndex + 10)
            }
        }
    }

    // MARK: - File List

    private var fileList: some View {
        Group {
            if viewModel.isSearching {
                // Search results
                if viewModel.searchResults.isEmpty {
                    emptyState("未找到匹配的文件")
                } else {
                    fileListView(viewModel.searchResults)
                }
            } else {
                switch viewModel.selectedTab {
                case .favorites:
                    emptyState("暂无收藏的文件")
                case .recent:
                    emptyState("暂无最近访问的文件")
                case .browse:
                    if viewModel.isLoading && viewModel.files.isEmpty {
                        loadingView
                    } else if viewModel.files.isEmpty {
                        emptyState("此目录为空")
                    } else {
                        fileListView(viewModel.files)
                    }
                case .more:
                    moreTabView
                }
            }
        }
    }

    private func fileListView(_ items: [FileItem]) -> some View {
        List {
            ForEach(items) { item in
                FileRowView(
                    item: item,
                    onTap: {
                        if item.isDirectory {
                            viewModel.navigateTo(path: item.path)
                        }
                    },
                    onDelete: { viewModel.deleteItem(item) }
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .background(Color(.systemBackground))
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("加载中...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text(message)
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - More Tab

    private var moreTabView: some View {
        List {
            Section {
                Button { } label: {
                    Label("新建文件夹", systemImage: "folder.badge.plus")
                }
                Button { } label: {
                    Label("批量选择", systemImage: "checkmark.circle")
                }
                Button { } label: {
                    Label("排序方式", systemImage: "arrow.up.arrow.down")
                }
            } header: {
                Text("文件操作")
            }

            Section {
                Button { } label: {
                    Label("存储空间", systemImage: "internaldrive")
                }
                Button { } label: {
                    Label("回收站", systemImage: "trash")
                }
            } header: {
                Text("工具")
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Joke Cell

struct JokeCell: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("听说iPhone上可以管理文件了，安卓用户怎么说？😏")
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Text("安卓用户：哦。😐")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
