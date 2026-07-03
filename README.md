# MacLocksmith

A lightweight macOS Finder extension that resolves "file in use" errors by identifying and terminating the underlying blocking process.

## Features
* **Native Finder Integration:** Adds an "Unlock File..." action directly to the macOS context menu.
* **Process Identification:** Uses `lsof` to locate the specific Process ID (PID) retaining the file lock.
* **Direct Termination:** Executes `kill -9` to force-quit the blocking application.
* **Auto-Quit:** Configurable option to terminate the utility immediately after execution.

## Installation
1. Download the latest `MacLocksmith.dmg` from the [Releases](../../releases) tab.
2. Mount the disk image and drag `MacLocksmith.app` to your `/Applications` directory.
3. Launch the application once to register the bundled extension with macOS.
4. Navigate to **System Settings > Privacy & Security > Extensions > Added extensions** and enable MacLocksmith.

*Note: As an unsigned application, Gatekeeper will require manual approval on the first launch (Right-click the app in Finder > Open).*

## Building from Source
1. Clone the repository and open `MacLocksmith.xcodeproj`.
2. Navigate to **Product > Scheme > Edit Scheme** and set the Build Configuration to **Release**.
3. Build the project (`Cmd + B`).
4. Locate `MacLocksmith.app` in `Products/Release` via **Product > Show Build Folder in Finder**.

## License
MIT License. Developed by Shiv.
