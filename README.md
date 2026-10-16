# CodeScribe

**A quiet place to write code.**

CodeScribe keeps the essentials close: your files on the left, your code in the center, and just enough control to make the editor feel like yours. It is built with SwiftUI and powered by [SwiftyMonaco](https://github.com/systemsoftware/SwiftyMonaco).

The goal is a simple editor, without a long list of extras. CodeScribe is still early in development, and updates will be occasional (whenever I feel like coming back to it).

## What you can do

- **Find your way around.** Open a folder and explore its files in a nested sidebar.
- **Get straight to editing.** Open text files with syntax highlighting based on their extensions.
- **Keep assets in view.** Preview PNG, JPEG, GIF, SVG, WebP, and HEIC images alongside your code.
- **Make room for your style.** Adjust the theme, font size, minimap, scrollbar, and cursor behavior in Settings.
- **Stay in the flow.** Save with **⌘S**, or let Auto Save write changes after a short pause.
- **Handle the small chores.** Create files and folders, reveal items in Finder on macOS, or move them to Trash.

## Start writing

1. Open `Code.xcodeproj` in Xcode.
2. Let Xcode resolve the SwiftyMonaco package dependency.
3. Select a supported destination and run the `Code` scheme.
4. Choose **Open Folder**, select a project, and pick a file from the sidebar.

The project currently targets macOS 15, iOS 17, and visionOS 1. Its Xcode target and scheme still use the name `Code`.

## License

See [LICENSE](LICENSE).
