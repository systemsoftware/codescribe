#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import SwiftUI


struct UniversalImage: View {
    
    var data: Data? = nil
    
    var url: URL? = nil
    
    init(data: Data? = nil, url: URL? = nil) {
        self.data = data
        
        if url != nil {
            self.data = try? Data(contentsOf: url!)
        }
    }
    
    var body: some View {
        #if os(macOS)
        Image(nsImage: NSImage(data: data ?? Data())!)
            .resizable()
            .scaledToFit()
        //    .frame(width: 100, height: 100)
        #elseif os(iOS)
        Image(uiImage: UIImage(data: data ?? Data())!)
            .resizable()
            .scaledToFit()
         //   .frame(width: 100, height: 100)
        #endif
    }
    
}
