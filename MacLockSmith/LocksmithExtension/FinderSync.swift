import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    override init() {
        super.init()
        // Monitor the entire Mac hard drive
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    // Create the right-click menu item
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        let item = NSMenuItem(title: "Unlock File...", action: #selector(unlockFile), keyEquivalent: "")
        item.target = self
        menu.addItem(item)
        return menu
    }

    // Triggered when the user clicks the menu item
    @IBAction func unlockFile(_ sender: AnyObject?) {
        guard let target = FIFinderSyncController.default().selectedItemURLs()?.first else { return }
        
        // Encode the file path so it safely fits in a URL
        let safePath = target.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Call your main app using the custom URL scheme
        if let url = URL(string: "maclocksmith://?path=\(safePath)") {
            NSWorkspace.shared.open(url)
        }
    }
}
