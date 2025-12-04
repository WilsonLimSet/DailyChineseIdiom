//
//  SpeechService.swift
//  DailyChineseIdiom
//
//  Created by Wilson Lim Setiawan on 12/4/25.
//

import AVFoundation

@MainActor
class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false

    /// Returns true if user has downloaded an enhanced or premium Mandarin voice
    var hasHighQualityVoice: Bool {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        return voices.contains { voice in
            voice.language == "zh-CN" && voice.quality != .default
        }
    }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)

        // Use Mandarin Chinese voice
        utterance.voice = findBestMandarinVoice()

        // Slower rate for learning
        utterance.rate = 0.35
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    private func findBestMandarinVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()

        // Filter for Mandarin Chinese voices (zh-CN) only
        let mandarinVoices = voices.filter { $0.language == "zh-CN" }

        // Sort by quality (premium > enhanced > default)
        let sortedVoices = mandarinVoices.sorted { $0.quality.rawValue > $1.quality.rawValue }

        // Return best quality available
        if let bestVoice = sortedVoices.first {
            return bestVoice
        }

        // Fallback: use specific Ting-Ting voice identifier to avoid iOS 18 bug
        // where zh-CN might incorrectly use Cantonese if Siri is set to Cantonese
        if let tingTing = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Ting-Ting-compact") {
            return tingTing
        }

        // Last resort fallback
        return AVSpeechSynthesisVoice(language: "zh-CN")
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}
