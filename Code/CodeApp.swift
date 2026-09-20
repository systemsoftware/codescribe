import SwiftUI
import SwiftData

@main
struct CodeApp: App {
  /*  var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    */
    @State var activeFile: File? = nil
    @State var openFiles: [File] = []

    var body: some Scene {
        WindowGroup(id: "document-window") {
            ContentView(activeFile: $activeFile, openFiles: $openFiles)
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
