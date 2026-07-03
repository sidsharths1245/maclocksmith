import SwiftUI
import AppKit

struct SettingsView: View {
    // This connects to the exact same memory flag you made for the onboarding screen
    @AppStorage("hasFinishedOnboarding") private var hasFinishedOnboarding: Bool = true

    var body: some View {
        TabView {
            // General Tab
            Form {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Finder Extension")
                        .font(.headline)
                    
                    Text("To use MacLocksmith, the Finder extension must be enabled.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Open System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    Text("Troubleshooting")
                        .font(.headline)
                    
                    Toggle("Skip Onboarding Screen on Launch", isOn: $hasFinishedOnboarding)
                        .help("Uncheck this to view the setup instructions again the next time you open the app.")
                }
                .padding(20)
            }
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
        }
        .frame(width: 400, height: 250)
    }
}
