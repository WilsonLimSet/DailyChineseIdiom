import SwiftUI
import WidgetKit

struct SettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    @StateObject private var speechService = SpeechService.shared

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
            
            Section(header: Text("Pronunciation")) {
                HStack {
                    Image(systemName: speechService.hasHighQualityVoice ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(speechService.hasHighQualityVoice ? .green : .orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(speechService.hasHighQualityVoice ? "Enhanced Voice Installed" : "Using Default Voice")
                            .font(.body)

                        if !speechService.hasHighQualityVoice {
                            Text("Download an enhanced voice for clearer pronunciation")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)

                if !speechService.hasHighQualityVoice {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to download:")
                            .font(.caption)
                            .fontWeight(.medium)

                        VStack(alignment: .leading, spacing: 4) {
                            Label("Open Settings app", systemImage: "1.circle.fill")
                            Label("Accessibility → Spoken Content", systemImage: "2.circle.fill")
                            Label("Voices → Chinese → Mandarin", systemImage: "3.circle.fill")
                            Label("Tap a voice → Download Enhanced", systemImage: "4.circle.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Button(action: {
                    speechService.speak("你好")
                }) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Test Pronunciation")
                    }
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("Support")) {
                Button(action: {
                    ReviewManager.shared.openAppStoreForReview()
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Rate & Review on App Store")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                Text("Your reviews help other users discover the app!")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
