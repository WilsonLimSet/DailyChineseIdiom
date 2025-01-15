//
//  ContentView.swift
//  DailyChineseIdiom
//
//  Created by Wilson Lim Setiawan on 1/4/25.
//

import SwiftUI

struct ContentView: View {
    let idiom: Idiom = IdiomProvider.shared.idiomForDate()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Today and Year
                HStack {
                    Text("TODAY")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(16)
                    
                    Spacer()
                }
                .padding(.top)
                
                // Main Characters
                Text(idiom.characters)
                    .font(.system(size: 42, weight: .bold))
                
                // Pinyin and Meaning
                VStack(alignment: .leading, spacing: 8) {
                    Text(idiom.pinyin)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(idiom.meaning)
                        .font(.title3)
                }
                
                // Divider line
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.2))
                
                // Example section
                if let example = idiom.example {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Example Usage")
                            .font(.headline)
                        
                        if let chineseExample = idiom.chineseExample {
                            Text(chineseExample)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(example)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Description or additional info
                Text(idiom.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let shareText = """
                    Daily Chinese Idiom
                    
                    \(idiom.characters)
                    \(idiom.pinyin)
                    \(idiom.meaning)
                    
                    Example:
                    \(idiom.chineseExample ?? "")
                    \(idiom.example ?? "")
                    
                    \(idiom.description)
                    """
                    
                    let activityVC = UIActivityViewController(
                        activityItems: [shareText],
                        applicationActivities: nil
                    )
                    
                    // For iPad support
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        activityVC.popoverPresentationController?.sourceView = rootVC.view
                        activityVC.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                        activityVC.popoverPresentationController?.permittedArrowDirections = []
                        rootVC.present(activityVC, animated: true)
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Image(systemName: "doc.text")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
