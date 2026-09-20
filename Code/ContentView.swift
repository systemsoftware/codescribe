import SwiftUI
import SwiftData
import SwiftyMonaco
internal import UniformTypeIdentifiers

func moveToTrash(url: URL) {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            var resultingURL: NSURL?
            // Execute the system trash operation
            try fileManager.trashItem(at: url, resultingItemURL: &resultingURL)
            
            if let trashedPath = resultingURL? .path {
                print("Trashed location: \(trashedPath)")
            }
        } catch {
            print(error)
        }
    }


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
    
    @Binding var activeFile: File?
    @State var selDir: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    @State var files: [File] = []
    @State private var securityScopedDirectory: URL?
    
    @State var showImporter = false
    
    @State var moveToTrashItem: File? = nil
    
    @State var showNewFile = false
    @State var newFileName = ""
    @State var newFileType = 0
    
    @ViewBuilder
    func contextMenu(_ item: File) -> some View {
        
        Text(item.name)
            .disabled(true)
        
        Divider()
        
        #if os(macOS)
        Button("Reveal in Finder") {
            NSWorkspace.shared.selectFile(item.url.path, inFileViewerRootedAtPath: item.url.deletingLastPathComponent().path)
        }
        #endif
        
        Button("Trash") {
            moveToTrashItem = item
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $activeFile) {
                if let selDir = selDir {
                    Section(selDir.lastPathComponent) {
                        OutlineGroup(files, id: \.id, children: \.children) { item in
                            if item.isDirectory {
                                Label(item.name, systemImage: "folder")
                                    .foregroundColor(.primary)
                                    .contextMenu {
                                        contextMenu(item)
                                    }

                            } else {
                                Label(item.name, systemImage: systemImage(for: item))
                                    .tag(item)
                                    .contextMenu {
                                        contextMenu(item)
                                    }
                            }
                        }
                    }
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 400)
#endif
            .navigationTitle(selDir?.lastPathComponent ?? "Files")
            .alert(item: $moveToTrashItem) { item in
                Alert(
                    title: Text("Move to Trash"),
                    message: Text("Are you sure you want to move '\(item.name)' to the Trash?"),
                    primaryButton: .destructive(Text("Move to Trash")) {
                        moveToTrash(url: item.url)
                        if let index = files.firstIndex(of: item) {
                            files.remove(at: index)
                        }
                        if activeFile == item {
                            activeFile = nil
                        }
                    },
                    secondaryButton: .cancel() {
                        moveToTrashItem = nil
                    }
                )
            }
            .sheet(isPresented: $showNewFile) {
                VStack {
                    Text("New File")
                        .font(.headline)
                        .padding()
                    
                    Picker("File Type", selection: $newFileType) {
                        Text("File").tag(0)
                        Text("Directory").tag(1)
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("File Name", text: $newFileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    HStack {
                        Button("Cancel") {
                            showNewFile = false
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button("Create", role:.confirm) {
                            let path = selDir?.appendingPathComponent(newFileName) ?? URL(fileURLWithPath: newFileName)
                            do {
                                if newFileType == 0 {
                                    try createFile(at: path, string: "")
                                } else {
                                    try mkDir(at: path)
                                }
                            } catch {
                                print("Failed to create \(newFileType == 0 ? "file" : "directory"): \(error)")
                            }
                            if let selDir = selDir {
                                files = loadContents(of: selDir)
                            }
                            showNewFile = false
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showNewFile.toggle()
                    } label: {
                        Label("New File", systemImage: "plus")
                    }
                }

                ToolbarItem {
                    Button {
                        showImporter.toggle()
                    } label: {
                        Label("Open Folder", systemImage: "folder")
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
                            showImporter.toggle()
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
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.folder]) { result in
            switch result {
            case .success(let url):
                if let securityScopedDirectory {
                    securityScopedDirectory.stopAccessingSecurityScopedResource()
                }

                let isSecurityScoped = url.startAccessingSecurityScopedResource()
                securityScopedDirectory = isSecurityScoped ? url : nil

                selDir = url
                files = loadContents(of: url)
                activeFile = findFirstFile(in: files)
            case .failure(let error):
                print("Failed to import folder: \(error)")
            }
        }
        .onDisappear {
            securityScopedDirectory?.stopAccessingSecurityScopedResource()
            securityScopedDirectory = nil
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

}
