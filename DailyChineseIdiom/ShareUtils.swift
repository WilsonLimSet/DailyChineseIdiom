import SwiftUI

struct ShareUtils {
    static func formatShareText(idiom: Idiom, date: Date, dateFormatter: DateFormatter) -> String {
        let preferences = UserPreferences.shared
        let meaning = preferences.getMeaningForIdiom(idiom)
        let characters = preferences.getCharactersForIdiom(idiom)
        let chineseExample = preferences.getChineseExampleForIdiom(idiom)
        let description = preferences.getDescriptionForIdiom(idiom)
        
        return """
        Daily Chinese Idiom
        \(dateFormatter.string(from: date))
        
        \(characters)
        \(idiom.pinyin)
        \(meaning)
        
        Example Applicable Situation:
        \(chineseExample ?? "")
        \(idiom.example ?? "")
        
        History & Meaning:
        \(description)
        
        Learn more at https://www.chineseidioms.com
        """
    }
    
    static func copyToClipboard(text: String, showToast: @escaping (Bool) -> Void) {
        UIPasteboard.general.string = text
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showToast(true)
        }
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                showToast(false)
            }
        }
    }
    
    static func presentShareSheet(text: String) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = []
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct CopyToastView: View {
    var body: some View {
        Text("Copied to Clipboard")
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.75))
            )
    }
} 