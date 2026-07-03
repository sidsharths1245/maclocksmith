import SwiftUI
import AppKit

struct ContentView: View {
    // Memory Flags
    @AppStorage("hasFinishedOnboarding") private var hasFinishedOnboarding: Bool = false
    @AppStorage("quitAfterUnlock") private var quitAfterUnlock: Bool = true
    
    // Active File States
    @State private var targetFile: String = ""
    @State private var blockingProcess: String = ""
    @State private var blockingPID: String = ""
    @State private var isLocked: Bool = false
    @State private var isProcessingFile: Bool = false

    var body: some View {
        Group {
            if !hasFinishedOnboarding {
                onboardingView
            } else {
                ZStack {
                    // Show the dashboard if we aren't actively processing a file
                    if !isProcessingFile {
                        dashboardView
                    }
                    
                    // Show the execution screen if a file was sent from Finder
                    if isProcessingFile {
                        executionView
                    }
                }
            }
        }
        .onOpenURL { url in
            handleIncomingURL(url)
        }
    }
    
    // --- 1. THE ONBOARDING SCREEN ---
    var onboardingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Welcome to MacLocksmith")
                .font(.title)
                .bold()
            
            Text("To add the 'Unlock File...' button to your right-click menu, you need to enable the extension in System Settings.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("1. Click the button below to open Settings.")
                Text("2. Go to **Added extensions**.")
                Text("3. Check the box next to **MacLocksmith**.")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            HStack(spacing: 15) {
                Button("Open Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences") {
                        NSWorkspace.shared.open(url)
                    }
                }
                
                Button("I've Enabled It") {
                    hasFinishedOnboarding = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 450, height: 380)
    }
    
    // --- 2. THE MAIN SETTINGS DASHBOARD ---
    var dashboardView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("MacLocksmith")
                .font(.largeTitle)
                .bold()
            
            Divider()
            
            // Extension Status Block
            VStack(alignment: .leading, spacing: 10) {
                Text("Finder Extension")
                    .font(.headline)
                Text("The extension must be checked in your system settings to appear in the right-click menu.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Open Extension Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Preferences Block
            VStack(alignment: .leading, spacing: 15) {
                Text("Preferences")
                    .font(.headline)
                
                Toggle("Quit automatically after unlocking a file", isOn: $quitAfterUnlock)
                
                Button("View Setup Instructions Again") {
                    hasFinishedOnboarding = false
                }
                .buttonStyle(.link)
                .font(.caption)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .frame(width: 450, height: 400)
    }
    
    // --- 3. THE EXECUTIONER SCREEN ---
    var executionView: some View {
        VStack(spacing: 20) {
            Text("Target File:\n\(targetFile)")
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .truncationMode(.middle)
            
            Divider()
            
            if isLocked {
                Text("⚠️ Locked By: \(blockingProcess)")
                    .foregroundColor(.red)
                    .font(.title3)
                Text("PID: \(blockingPID)")
                    .font(.caption)
                
                Button("Force Kill Process") {
                    killProcess(pid: blockingPID)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
            } else {
                Text("✅ File is clear.")
                    .foregroundColor(.green)
                    .font(.title3)
            }
            
            Spacer().frame(height: 10)
            
            Button("Close") {
                if quitAfterUnlock {
                    NSApplication.shared.terminate(nil)
                } else {
                    isProcessingFile = false
                    targetFile = ""
                }
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(width: 400, height: 250)
        // This background ensures it visually blocks the dashboard entirely if they overlap
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // --- ENGINE LOGIC ---
    
    func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItem = components.queryItems?.first(where: { $0.name == "path" }),
              let path = queryItem.value else { return }
        
        targetFile = path
        isProcessingFile = true
        checkFileLock(path: path)
    }

    func checkFileLock(path: String) {
        if path.hasSuffix(".app") {
            let runningApps = NSWorkspace.shared.runningApplications
            if let targetApp = runningApps.first(where: { $0.bundleURL?.path == path }) {
                blockingPID = String(targetApp.processIdentifier)
                blockingProcess = targetApp.localizedName ?? URL(fileURLWithPath: path).lastPathComponent
                isLocked = true
            } else {
                isLocked = false
            }
            return
        }
        
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        task.arguments = ["-t", path]
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let pid = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !pid.isEmpty {
                blockingPID = pid
                getProcessName(pid: pid)
                isLocked = true
            } else {
                isLocked = false
            }
        } catch {
            print("Failed to run lsof")
        }
    }
    
    func getProcessName(pid: String) {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-p", pid, "-o", "comm="]
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                blockingProcess = URL(fileURLWithPath: output.trimmingCharacters(in: .whitespacesAndNewlines)).lastPathComponent
            }
        } catch {}
    }
    
    func killProcess(pid: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/kill")
        task.arguments = ["-9", pid]
        try? task.run()
        isLocked = false
        blockingProcess = ""
        
        if quitAfterUnlock {
            NSApplication.shared.terminate(nil)
        }
    }
}
