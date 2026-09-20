import SwiftUI
import SwiftData

@main
struct CodeApp: App {
    var sharedModelContainer: ModelContainer = {
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
    
    @State var activeFile: File? = nil

    var body: some Scene {
        WindowGroup {
            ContentView(activeFile: $activeFile)
                .navigationTitle(activeFile?.name ?? "Code")
        }
        .modelContainer(sharedModelContainer)
    }
}
