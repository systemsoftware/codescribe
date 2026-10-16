import SwiftUI
import SwiftyMonaco

struct EditorView: View {
    let file: File
    @State private var text: String
    
    @State private var debounceTask: Task<Void, Never>? = nil
    
    @Binding var hasUnsaved: Bool
    
    @AppStorage("minimap") private var minimapEnabled: Bool = true
    @AppStorage("fontSize") private var fontSize: Int = 14
    @AppStorage("autoSave") private var autoSaveEnabled: Bool = true
    @AppStorage("scrollbar") private var scrollbarEnabled: Bool = true
    @AppStorage("smoothCursor") private var smoothCursorEnabled: Bool = false
    @AppStorage("cursorBlink") private var cursorBlink: String = "blink"
    @AppStorage("theme") private var editorTheme: String = "system"

    init(file: File, hasUnsaved: Binding<Bool>) {
        self.file = file
        _text = State(initialValue: (try? String(contentsOf: file.url, encoding: .utf8)) ?? "")
        self._hasUnsaved = hasUnsaved
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
            .background {
                      Button("") {
                          Task {
                              await performSave(text)
                          }
                      }
                      .keyboardShortcut("s", modifiers: .command)
                  }
            .onChange(of: text) { _, newValue in
                if !autoSaveEnabled {
                    
                    hasUnsaved = true
                    
                    return
                }
                
                debounceTask?.cancel()
                
                debounceTask = Task {
                    await performSave(newValue)
                }
            }
    }
    
    func performSave(_ newValue: String) async {
        do {
            try await Task.sleep(for: .seconds(1))
            let fileURL = file.url
            try newValue.write(to: fileURL, atomically: true, encoding: .utf8)
            hasUnsaved = false
        } catch {
            print("Write cancelled or failed: \(error)")
        }
    }
}
