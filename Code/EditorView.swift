import SwiftUI
import SwiftyMonaco

struct EditorView: View {
    let file: File
    @State private var text: String
    
    @AppStorage("minimap") private var minimapEnabled: Bool = true
    @AppStorage("fontSize") private var fontSize: Int = 14

    init(file: File) {
        self.file = file
        _text = State(initialValue: (try? String(contentsOf: file.url, encoding: .utf8)) ?? "")
    }

    var body: some View {
        SwiftyMonaco(text: $text)
            .minimap(minimapEnabled)
            .fontSize(fontSize)
            .syntaxHighlight(fileExtension: file.url.pathExtension.lowercased())
            .onChange(of: text) { _, newValue in
                try? newValue.write(to: file.url, atomically: true, encoding: .utf8)
            }
    }
}
