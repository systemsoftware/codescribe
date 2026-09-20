import Foundation
import FileProvider


func createFile(at url: URL, string: String) throws {
    let fileManager = FileManager.default
    let directoryURL = url.deletingLastPathComponent()
    
    // Ensure the directory exists
    if !fileManager.fileExists(atPath: directoryURL.path) {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    let contents = Data(string.utf8)
    
    // Create the file with the specified contents
    try contents.write(to: url)
}


func mkDir(at url: URL) throws {
    let fileManager = FileManager.default
    
    if !fileManager.fileExists(atPath: url.path) {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}

