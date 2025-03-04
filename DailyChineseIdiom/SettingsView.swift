import SwiftUI
import WidgetKit

struct SettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    
    var body: some View {
        List {
            Section(header: Text("Display Options")) {
                Picker("Meaning Display", selection: $preferences.showMetaphoricMeaning) {
                    Text("Literal Translation")
                        .tag(false)
                    Text("Deeper Meaning")
                        .tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
                
                Text("Choose how idioms are translated in the app and widgets")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            Section(header: Text("Example")) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("塞翁失马")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Literal Translation:")
                                .font(.headline)
                            Text("Old man loses horse")
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Deeper Meaning:")
                                .font(.headline)
                            Text("Misfortune might be a blessing")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
