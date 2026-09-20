import SwiftUI
import SwiftyMonaco

struct EditorView: View {
    let file: File
    @State private var text: String
    
    @State private var debounceTask: Task<Void, Never>? = nil
    
    @AppStorage("minimap") private var minimapEnabled: Bool = true
    @AppStorage("fontSize") private var fontSize: Int = 14
    @AppStorage("autoSave") private var autoSaveEnabled: Bool = true
    @AppStorage("scrollbar") private var scrollbarEnabled: Bool = true
    @AppStorage("smoothCursor") private var smoothCursorEnabled: Bool = false
    @AppStorage("cursorBlink") private var cursorBlink: String = "blink"
    @AppStorage("theme") private var editorTheme: String = "system"

    init(file: File) {
        self.file = file
        _text = State(initialValue: (try? String(contentsOf: file.url, encoding: .utf8)) ?? "")
    }

    private var blinkStyle: CursorBlink {
        switch cursorBlink {
        case "smooth": return .smooth
        case "phase": return .phase
        case "expand": return .expand
        case "solid": return .solid
        default: return .blink
        }
    }

    private var monacoTheme: Theme? {
        switch editorTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    @ViewBuilder
    private var monacoEditor: some View {
        let base = SwiftyMonaco(text: $text)
            .minimap(minimapEnabled)
            .fontSize(fontSize)
            .scrollbar(scrollbarEnabled)
            .smoothCursor(smoothCursorEnabled)
            .cursorBlink(blinkStyle)
            .syntaxHighlight(fileExtension: file.url.pathExtension.lowercased())
        
        if let monacoTheme {
            base.theme(monacoTheme)
        } else {
            base
        }
    }

    var body: some View {
        monacoEditor
            .id("\(file.id)-\(minimapEnabled)-\(fontSize)-\(scrollbarEnabled)-\(smoothCursorEnabled)-\(cursorBlink)-\(editorTheme)")
            .onChange(of: text) { _, newValue in
                if !autoSaveEnabled {
                    return
                }
                
                debounceTask?.cancel()
                
                debounceTask = Task {
                    do {
                        try await Task.sleep(for: .seconds(1))
                        let fileURL = file.url
                        try newValue.write(to: fileURL, atomically: true, encoding: .utf8)
                    } catch {
                        print("Write cancelled or failed: \(error)")
                    }
                }
            }
    }
}
