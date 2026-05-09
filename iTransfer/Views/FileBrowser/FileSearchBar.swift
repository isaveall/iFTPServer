import SwiftUI

struct FileSearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void
    var onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 15))

            TextField("搜索文件...", text: $text)
                .font(.system(size: 15))
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit() }

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onClear()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}
