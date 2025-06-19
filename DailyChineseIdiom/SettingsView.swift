import SwiftUI
import WidgetKit

struct SettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    
    var body: some View {
        List {
            Section(header: Text("Character Display")) {
                Picker("Character Type", selection: $preferences.useTraditionalCharacters) {
                    Text("Simplified")
                        .tag(false)
                    Text("Traditional")
                        .tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
                
                Text("Choose between simplified and traditional Chinese characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            Section(header: Text("Meaning Display")) {
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
                    Text(preferences.getCharactersForIdiom(sampleIdiom))
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
