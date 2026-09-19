//
//  ContentView.swift
//  Code
//
//  Created by Bryce Agostini on 9/19/26.
//

import SwiftUI
import SwiftData
import SwiftyMonaco

enum FileType: String, Hashable {
    case file = "file"
    case directory = "directory"
}

struct File: Identifiable, Hashable {
    var id: String { url.path }
    let name: String
    let type: FileType
    let url: URL
    var children: [File]?
    
    var isDirectory: Bool {
        type == .directory
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State var activeFile: File? = nil
    @State var selDir: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    @State var files: [File] = []
    
    var body: some View {
        NavigationSplitView {
            List(selection: $activeFile) {
                if let selDir = selDir {
                    Section(selDir.lastPathComponent) {
                        OutlineGroup(files, id: \.id, children: \.children) { item in
                            if item.isDirectory {
                                Label(item.name, systemImage: "folder")
                                    .foregroundColor(.primary)
                            } else {
                                Label(item.name, systemImage: systemImage(for: item))
                                    .tag(item)
                            }
                        }
                    }
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 400)
#endif
            .navigationTitle(selDir?.lastPathComponent ?? "Files")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        loadDir()
                    } label: {
                        Label("Open Folder", systemImage: "folder.badge.plus")
                    }
                }
            }
            .task(id: selDir) {
                if let selDir = selDir {
                    files = loadContents(of: selDir)
                    if activeFile == nil {
                        activeFile = findFirstFile(in: files)
                    }
                }
            }
        } detail: {
            if let activeFile = activeFile, !activeFile.isDirectory {
                EditorView(file: activeFile)
                    .id(activeFile.id)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "curlybraces.square")
                        .font(.system(size: 56))
                        .foregroundColor(.secondary)
                    
                    Text("Welcome to Code")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if files.isEmpty {
                        Text("No directory loaded. Open a folder to browse and edit files.")
                            .foregroundColor(.secondary)
                        
                        Button("Open Directory") {
                            loadDir()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("Select a file from the sidebar to start editing.")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
    }
    
    private func loadContents(of url: URL) -> [File] {
        let fileManager = FileManager.default
        guard let entries = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        var loadedFiles: [File] = []
        for entry in entries {
            let resourceValues = try? entry.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey])
            let isPackage = resourceValues?.isPackage ?? false
            let isDirectory = (resourceValues?.isDirectory ?? false) && !isPackage
            
            let type: FileType = isDirectory ? .directory : .file
            let children: [File]? = isDirectory ? loadContents(of: entry) : nil
            
            loadedFiles.append(
                File(
                    name: entry.lastPathComponent,
                    type: type,
                    url: entry,
                    children: children
                )
            )
        }
        
        return loadedFiles.sorted {
            if $0.isDirectory != $1.isDirectory {
                return $0.isDirectory && !$1.isDirectory
            }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
    
    private func findFirstFile(in files: [File]) -> File? {
        for file in files {
            if !file.isDirectory {
                return file
            }
            if let children = file.children, let firstSub = findFirstFile(in: children) {
                return firstSub
            }
        }
        return nil
    }
    
    private func systemImage(for file: File) -> String {
        let ext = file.url.pathExtension.lowercased()
        switch ext {
        case "swift":
            return "swift"
        case "json", "xml", "plist":
            return "curlybraces"
        case "html", "htm", "css", "js", "ts", "jsx", "tsx":
            return "chevron.left.forwardslash.chevron.right"
        case "md", "markdown", "txt", "rtf":
            return "doc.plaintext"
        case "png", "jpg", "jpeg", "gif", "svg", "webp", "heic":
            return "photo"
        case "c", "cpp", "h", "hpp", "m", "mm":
            return "c.square"
        case "py":
            return "chevron.left.slash.chevron.right"
        default:
            return "doc"
        }
    }
    
    private func loadDir() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Open"
        if panel.runModal() == .OK {
            if let url = panel.url {
                files = []
                selDir = url
                activeFile = nil
            }
        }
    }
}
