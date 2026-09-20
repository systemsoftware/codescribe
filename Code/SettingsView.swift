import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("fontSize") private var fontSize: Int = 14
    @AppStorage("minimap") private var minimapEnabled: Bool = true
    @AppStorage("scrollbar") private var scrollbarEnabled: Bool = true
    @AppStorage("smoothCursor") private var smoothCursorEnabled: Bool = false
    @AppStorage("cursorBlink") private var cursorBlink: String = "blink"
    @AppStorage("theme") private var editorTheme: String = "system"
    @AppStorage("autoSave") private var autoSaveEnabled: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker(selection: $editorTheme) {
                        Label("System", systemImage: "circle.lefthalf.filled").tag("system")
                        Label("Dark", systemImage: "moon.fill").tag("dark")
                        Label("Light", systemImage: "sun.max.fill").tag("light")
                    } label: {
                        Label("Theme", systemImage: "paintpalette")
                    }
                    
                    Stepper(value: $fontSize, in: 10...36) {
                        HStack {
                            Label("Font Size", systemImage: "textformat.size")
                            Spacer()
                            Text("\(fontSize) pt")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Editor Display") {
                    Toggle(isOn: $minimapEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Minimap", systemImage: "map")
                            Text("Display code overview sidebar on the right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Toggle(isOn: $scrollbarEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Scrollbar", systemImage: "arrow.up.and.down")
                            Text("Show vertical scrollbar in the editor")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Toggle(isOn: $smoothCursorEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Smooth Cursor Animation", systemImage: "cursorarrow.motionlines")
                            Text("Animate the cursor when moving between positions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Picker(selection: $cursorBlink) {
                        Text("Blink").tag("blink")
                        Text("Smooth").tag("smooth")
                        Text("Phase").tag("phase")
                        Text("Expand").tag("expand")
                        Text("Solid").tag("solid")
                    } label: {
                        Label("Cursor Blinking", systemImage: "cursorarrow.rays")
                    }
                }
                
                Section("Files & Saving") {
                    Toggle(isOn: $autoSaveEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Auto Save", systemImage: "square.and.arrow.down")
                            Text("Automatically save modifications after typing pauses")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        resetToDefaults()
                    } label: {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 460, idealWidth: 500, minHeight: 460, idealHeight: 520)
        #endif
    }
    
    private func resetToDefaults() {
        fontSize = 14
        minimapEnabled = true
        scrollbarEnabled = true
        smoothCursorEnabled = false
        cursorBlink = "blink"
        editorTheme = "system"
        autoSaveEnabled = true
    }
}
