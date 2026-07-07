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
4. Navigate to **System Settings > General > Login Items & Extensions > Extensions** and enable MacLocksmith.

*Note: As an unsigned application, Gatekeeper will require manual approval on the first launch (Right-click the app in Finder > Open).*

## Usage
Once installed and enabled, using MacLocksmith takes exactly two clicks:

1. **Locate the File:** Find the locked or stubborn file in macOS Finder.
2. **Right-Click:** Right-click the file and select **"Unlock File..."** from the context menu. 
3. **Identify the Culprit:** The MacLocksmith window will instantly appear, showing you the exact background process and PID holding your file hostage.
4. **Kill It:** Click the red **Force Kill Process** button. The blocking application is immediately terminated, freeing your file.

*(If you have "Quit automatically" enabled in the main app preferences, MacLocksmith will instantly close itself after a successful kill).*

## Building from Source
1. Clone the repository and open `MacLocksmith.xcodeproj`.
2. Navigate to **Product > Scheme > Edit Scheme** and set the Build Configuration to **Release**.
3. Build the project (`Cmd + B`).
4. Locate `MacLocksmith.app` in `Products/Release` via **Product > Show Build Folder in Finder**.
