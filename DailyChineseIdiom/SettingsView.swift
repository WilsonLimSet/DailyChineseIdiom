import SwiftUI
import WidgetKit

struct SettingsView: View {
    @StateObject private var preferences = UserPreferences.shared
    @StateObject private var speechService = SpeechService.shared
    @StateObject private var tipJar = TipJarManager.shared

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

                Text("Choose between simplified and traditional Chinese characters. Some idioms are written the same in both scripts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            Section(header: Text("Meaning Display")) {
                Picker("Meaning Display", selection: $preferences.meaningDisplayMode) {
                    Text("Literal")
                        .tag(MeaningDisplayMode.literal)
                    Text("Deeper")
                        .tag(MeaningDisplayMode.deeper)
                    Text("Both")
                        .tag(MeaningDisplayMode.both)
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

            if !tipJar.products.isEmpty {
                Section(header: Text("Tip Jar")) {
                    Text(tipJar.hasTipped
                         ? "Thank you for supporting Daily Chinese Idiom 谢谢!"
                         : "Daily Chinese Idiom is free, with no ads and no tracking. If it's part of your day, you can leave a tip.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)

                    ForEach(tipJar.products) { product in
                        Button(action: {
                            Task { await tipJar.purchase(product) }
                        }) {
                            HStack {
                                Text(tipJar.symbol(for: product))
                                    .font(.title3)
                                Text(product.displayName)
                                    .foregroundColor(.primary)
                                Spacer()
                                if tipJar.purchasingProductID == product.id {
                                    ProgressView()
                                } else {
                                    Text(product.displayPrice)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .disabled(tipJar.purchasingProductID != nil)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await tipJar.loadProducts()
        }
        .alert("谢谢! Thank you", isPresented: $tipJar.showThankYou) {
            Button("You're welcome", role: .cancel) { }
        } message: {
            Text("Your tip keeps Daily Chinese Idiom free and ad-free for everyone.")
        }
        .alert("Purchase Failed", isPresented: Binding(
            get: { tipJar.errorMessage != nil },
            set: { if !$0 { tipJar.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(tipJar.errorMessage ?? "")
        }
    }
}
